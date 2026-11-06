#include <iostream>
#include <sstream>
#include <fstream>

#include <boost/math/special_functions/digamma.hpp>
#include <boost/algorithm/string.hpp>

#include <chrono>

// Cross-platform ctime
#ifdef _WIN32
    #define ctime_r(t, buf) ctime_s(buf, sizeof(buf), t)
#endif

std::string GetTimeStamp() {
    auto now = std::chrono::system_clock::now();
    std::time_t t = std::chrono::system_clock::to_time_t(now);
    char buffer[26];

    // Use ctime_r for POSIX systems and ctime_s for Windows
    #ifdef _WIN32
        ctime_s(buffer, sizeof(buffer), &t);
    #else
        ctime_r(&t, buffer);
    #endif

    std::string timeStamp(buffer);
    timeStamp.pop_back();

    return timeStamp;
}

class RandomGenerator {
    // Generates p.random numbers (double). Optionally takes a seed, otherwise p.random seed.
public:
    int seed;
    RandomGenerator(int newSeed = -1) {

        seed = newSeed;

        if (seed == -1) {
            srand(time(0));
        }
        else {
            srand(seed);
        }
    }
    double Dbl() {
        double p = (double)rand() / RAND_MAX;
        return p;
    }
};

class ModelState {
public:
    // MODEL ELEMENTS

    // Data size and model spec and state:
    int nTok = -1;
    int nTerm = -1;
    int nDoc = -1;

    int nTop = -1;

    // Data
    std::vector<int> vTok;
    std::vector<int> vDoc;

    // Labels
    std::vector<int> vLab;

    // Count matrices
    std::vector<std::vector<int>> doctop;
    std::vector<int> docLength;

    std::vector<std::vector<int>> topterm;
    std::vector<int> topCount;

    // Priors
    double cAlpha = 0.01;
    double sAlpha = 100;
    std::vector<double> alpha;
    double alphaSum;

    bool etaKnown = false;
    double cEta = 0.01;
    double sEta = 100;
    std::vector<std::vector<double>> eta;
    std::vector<double> etaSum;

    double priorConvergenceThreshold = 0.01;

    // LOGGING
    int seed;
    RandomGenerator rnd;

    // N iterations done:
    int iterN = 0;

    // N iterations to do
    int maxIterN = 15000;

    // Start recording model parameters after N iterations
    int saveAfterN = 10000;

    // Save parameters every N iterations
    int saveEveryN = 10;

    // Read/write/save parameters
    std::string writePath;
    std::string readPath;
    std::string dataFileName = "corpus.csv";
    std::string etaFileName = "eta2.csv";

    ModelState(int argc, char* argv[]) {
        // Object constructor

        // Parse and save arguments
        ParseArguments(argc, argv);

        // Read the data
        ReadMainData();

        // UPDATE MODEL SIZE:
        // Resize labels
        vLab.resize(nTok);

        // Count matrices
        doctop.resize(nDoc, std::vector<int>(nTop));
        topterm.resize(nTop, std::vector<int>(nTerm));
        topCount.resize(nTop);

        // Priors
        alpha.resize(nTop, cAlpha * sAlpha);
        alphaSum = nTop * cAlpha * sAlpha;

        if (etaKnown) {
            ReadEta();
        }
        else {
            eta.resize(nTop, std::vector<double>(nTerm, cEta * sEta));
            etaSum.resize(nTop, nTerm * cEta * sEta);
        }
    }

    void UpdCounts(int drc, int w, int d, int k) {
        // Change the given count by drc
        doctop[d][k] += drc;
        topterm[k][w] += drc;
        topCount[k] += drc;
    }

    void AssignLabel(int n, bool decCount = true) {
        // Assigns label to the n-th token
        // Calculate probabilities for each topic and draw

        // Get data
        int w = vTok[n];
        int d = vDoc[n];
        int z = vLab[n];

        // Decrease counts, unless initializing
        if (decCount) {
            UpdCounts(-1, w, d, z);
        }

        // Get topic probabilities (proportions)
        std::vector<double> topicProps(nTop);
        double propSum = 0;

        for (int k = 0; k < nTop; k++) {

            // Document probability (proportion)
            double docProp = (double)doctop[d][k] + alpha[k];

            // Term probability
            double termProp = ((double)topterm[k][w] + eta[k][w]) / ((double)topCount[k] + etaSum[k]);

            // Record probability
            double topicProp = docProp * termProp;

            // For debugging only
            if (topicProp <= 0) {
                AddToLog("Topic label probability <= 0", 0);
                AddToLog("termProb = " + std::to_string(termProp) + ", eta" = std::to_string(eta[k][w]) + ", etaSum" + std::to_string(etaSum[k]), 0);
                throw;
            }

            propSum += topicProp;
            topicProps[k] = topicProp;
        }

        // Draw topic
        double p = rnd.Dbl();
        double cumTopicProb = 0;
        z = -1;

        for (int k = 0; k < nTop; k++) {

            // Avoid floating point error
            double topicProb = (k != nTop - 1) ? topicProps[k] / propSum : 1.0;
            cumTopicProb += topicProb;

            if (p <= cumTopicProb) {
                z = k;
                break;
            }
        }

        // Increase counts
        UpdCounts(1, w, d, z);

        // Assign label
        vLab[n] = z;

    }

    void InitializeLabels() {

        iterN = 0;
        AddToLog("Initializing labels.", 1);

        // Go through tokens and assign label
        for (int n = 0; n < nTok; n++) {
            AssignLabel(n, false);
        }

        AddToLog("Complete.", 2);
    }

    void DoIterations() {
        // Perform iterations
        for (iterN = 1; iterN <= maxIterN; iterN++) {
            UpdateLabels();

            // Optimize priors
            OptimizeAlpha();

            if (!etaKnown) {
                OptimizeEta();
            }

            // Record
            if (iterN >= saveAfterN) {
                if (((iterN - saveAfterN) % saveEveryN) == 0) {
                    RecordState();
                }
            }
        }
    }

    void UpdateLabels() {

        AddToLog("Update labels, iteration: " + std::to_string(iterN) + ", " + GetTimeStamp(), 1, false, true);

        // Go through tokens and assign label
        for (int n = 0; n < nTok; n++) {
            AssignLabel(n);
        }

        AddToLog("Complete.", 2);
    }

    void OptimizeAlpha() {

        AddToLog("Optimizing alpha", 1, false, true);

        // Perform fixed-point iteration until convergence
        bool converge = false;
        int iterAlpha = 0;

        while (!converge) {

            std::cout << ".";
            iterAlpha++;

            double change = DoStepAlphaAsymm();
            converge = (change < priorConvergenceThreshold);
        }

        AddToLog("\n     Finished after " + std::to_string(iterAlpha) + " iterations.", 2);
    }

    double DoStepAlphaAsymm() {
        // Do a single step of alpha optimization
        // Returns greatest elements-wise change from the previous

        // Set up new alpha
        std::vector<double> newAlpha(nTop);
        double newAlphaSum = 0;
        double maxChange = 0;

        for (int k = 0; k < nTop; k++) {
            double updNumer = 0;
            double updDenom = 0;

            // Iterate through the documents and calculate update
            for (int d = 0; d < nDoc; d++) {

                // Increment update
                updNumer += (boost::math::digamma(doctop[d][k] + alpha[k]) - boost::math::digamma(alpha[k]));
                updDenom += (boost::math::digamma(docLength[d] + alphaSum) - boost::math::digamma(alphaSum));
            }

            // Update alpha (for each group)
            double newAlphaElement = alpha[k] * (updNumer + cAlpha) / (updDenom + 1 / sAlpha);
            newAlpha[k] = newAlphaElement;
            newAlphaSum += newAlphaElement;

            // Record max change
            double change = abs(alpha[k] - newAlphaElement) / alpha[k];
            maxChange = std::max(maxChange, change);

        }

        alpha = newAlpha;
        alphaSum = newAlphaSum;

        // Return max change
        return maxChange;
    }

    void OptimizeEta() {
        AddToLog("Optimizing eta", 1, false, true);


        // Perform fixed-point iteration until convergence
        bool converge = false;
        int iterEta = 0;

        while (!converge) {

            std::cout << ".";

            iterEta++;

            double change = 1;

            change = DoStepEta();

            converge = (change < priorConvergenceThreshold);
        }

        AddToLog("\n     Finished after " + std::to_string(iterEta) + " iterations.", 2);

    }

    double DoStepEta() {
        // Do a single step of eta optimization
        // Returns change from the previous

        double updNumer = 0;
        double updDenom = 0;

        // If eta is unknown, all elements are the same
        double oldEta = eta[0][0];

        // Iterate through topics and terms and calculate the update
        for (int k = 0; k < nTop; k++) {
            for (int i = 0; i < nTerm; i++) {

                updNumer += (boost::math::digamma(topterm[k][i] + oldEta) - boost::math::digamma(oldEta));

            }

            updDenom += (boost::math::digamma(topCount[k] + nTerm * oldEta) - boost::math::digamma(nTerm * oldEta)) * nTerm;
        }

        // Update eta
        double newEta = oldEta * (updNumer + cEta) / (updDenom + 1.0 / sEta);
        double change = abs(oldEta - newEta) / oldEta;

        eta.assign(nTop, std::vector<double>(nTerm, newEta));
        etaSum.assign(nTop, nTerm * newEta);

        // Return change
        return change;
    }

    void ParseArguments(int argc, char* argv[]) {

        // Parse keyworded arguments
        for (int i = 1; i < argc; i++) {
            std::vector<std::string> arg;
            boost::algorithm::split(arg, argv[i], boost::is_any_of("="));
            if (arg.size() != 2) {
                AddToLog("Error reading argument at position " + std::to_string(i), 0);
            }

            bool saveSucc = SaveArg(arg[0], arg[1]);
            if (!saveSucc) {
                AddToLog("Error reading argument at position " + std::to_string(i), 0);
            }
        }

        AddToLog("Write path set to: " + writePath, 2);
        AddToLog("Read path set to: " + readPath, 2);
        AddToLog("Data file name: " + dataFileName, 2);
        AddToLog("Number of topics: " + std::to_string(nTop), 2);
        AddToLog("Alpha prior: " + std::to_string(cAlpha) + "," + std::to_string(sAlpha), 2);
        if (etaKnown) {
            AddToLog("Eta assumed to be known. Eta file name: " + etaFileName, 2);
        }
        else {
            AddToLog("Eta prior: " + std::to_string(cEta) + "," + std::to_string(sEta), 2);
        }
        AddToLog("Random seed: " + std::to_string(seed), 2);
        AddToLog("Number of iterations to perform: " + std::to_string(maxIterN), 2);
        AddToLog("Save after " + std::to_string(saveAfterN) + " iterations", 2);
        AddToLog("Save every " + std::to_string(saveEveryN) + " iterations", 2);

    }

    bool SaveArg(std::string argKey, std::string argVal) {

        // Save the value into the relevant variable
        if (argKey == "writePath") {
            writePath = argVal;

            WriteLine("", "log.txt", false);

            AddToLog(GetTimeStamp(), 1, false, true);
            AddToLog("New Grouped LDA model. Reading arguments --", 1);

            return true;
        }

        if (argKey == "readPath") {
            readPath = argVal;
            return true;
        }

        if (argKey == "dataFile") {
            dataFileName = argVal;
            return true;
        }

        if (argKey == "etaFile") {
            etaFileName = argVal;
            return true;
        }

        if (argKey == "nTop") {
            nTop = std::stoi(argVal);
            return true;
        }

        if (argKey == "cAlpha") {
            cAlpha = std::stod(argVal);
            return true;
        }

        if (argKey == "sAlpha") {
            sAlpha = std::stod(argVal);
            return true;
        }

        if (argKey == "etaKnown") {

            if (std::stoi(argVal) == 1) {
                etaKnown = true;
                return true;
            }
        }

        if (argKey == "cEta") {
            cEta = std::stod(argVal);
            return true;
        }

        if (argKey == "sEta") {
            sEta = std::stod(argVal);
            return true;
        }

        if (argKey == "seed") {
            seed = std::stoi(argVal);
            return true;
        }

        if (argKey == "maxIter") {
            maxIterN = std::stoi(argVal);
            return true;
        }

        if (argKey == "saveAfter") {
            saveAfterN = std::stoi(argVal);
            return true;
        }

        if (argKey == "saveEvery") {
            saveEveryN = std::stoi(argVal);
            return true;
        }

        // If none of the conditions matched, return false
        return false;
    }

    void ReadMainData() {
        std::string dataPath = readPath + dataFileName;
        AddToLog("Reading data from " + dataPath, 1);

        // SETUP
        std::ifstream file(dataPath);
        std::string line;

        nTok = 0;
        nTerm = -1;
        nDoc = -1;

        // Iterate throuh each line
        while (std::getline(file, line)) {

            nTok++;

            // Split line on commas
            std::vector<std::string> svec;
            boost::algorithm::split(svec, line, boost::is_any_of(","));

            // Convert to vector of integers
            std::vector<int> ivec;

            for (std::string elem : svec) {
                ivec.push_back(std::stoi(elem));
            }

            // Data and size:
            // Save token
            int w = ivec[0];
            vTok.push_back(w);
            if (w + 1 > nTerm) {
                nTerm = w + 1;
            }

            // Save document
            int d = ivec[1];
            vDoc.push_back(d);
            if (d + 1 > nDoc) {
                nDoc = d + 1;
            }

            // Record doc length
            if (d + 1 > docLength.size()) {
                docLength.resize(d + 1);
            }
            docLength[d]++;
        }

        file.close();
        AddToLog("Complete. Tokens: " + std::to_string(nTok) + ", Docs: " + std::to_string(nDoc) + ", Terms: " + std::to_string(nTerm), 2);
    }

    void ReadEta() {
        std::string dataPath = readPath + etaFileName;
        AddToLog("Reading eta from " + dataPath, 1);

        // SETUP
        std::ifstream file(dataPath);
        std::string line;

        int iRow = 0;

        while (std::getline(file, line)) {

            // Split line on commas
            std::vector<std::string> svec;
            boost::algorithm::split(svec, line, boost::is_any_of(","));

            // Convert to vector of integers
            std::vector<double> etaRow;
            double etaRowSum = 0;

            for (std::string elem : svec) {
                double etaElem = std::stod(elem);
                etaRow.push_back(etaElem);
                etaRowSum += etaElem;
            }
            if (etaRow.size() != nTerm) {
                AddToLog("Wrong number of elements in eta row no. " + std::to_string(iRow), 0);
            }

            // Add row to eta
            eta.push_back(etaRow);
            etaSum.push_back(etaRowSum);

            iRow++;
        }

        if (eta.size() != nTop) {
            AddToLog("Wrong number of rows in eta", 0);
        }
    }

    void RecordState() {

        AddToLog("Writing data to " + writePath, 1);

        std::string savePath;

        int s = iterN;

        // Create iteration stamp for filenames
        char stamp[6];
        snprintf(stamp, 6, "%05d", s);

        // Theta and phi
        savePath = writePath + "doctop" + stamp + ".csv";
        IntToCsv(doctop, savePath);

        savePath = writePath + "topterm" + stamp + ".csv";
        IntToCsv(topterm, savePath);

        // Alpha and eta
        savePath = writePath + "alpha" + stamp + ".csv";
        DblToCsv(alpha, savePath);

        if (!etaKnown) {
            // If eta not know, all elements are equal, save just one
            savePath = writePath + "eta" + stamp + ".csv";
            WriteLine(std::to_string(eta[0][0]), savePath, false, true);
        }

        AddToLog("Complete.", 2);
    }

    void DblToCsv(std::vector<std::vector<double>> matin, std::string filename) {

        // Setup
        int ni = matin.size();
        int nj = matin[0].size();
        std::ofstream file(filename);

        // For each row, construct line and print
        for (int i = 0; i < ni; i++) {

            std::string line = "";

            for (int j = 0; j < nj; j++) {
                line += std::to_string(matin[i][j]);

                if (j < nj - 1) {
                    line += ",";
                }
            }

            if (i < ni - 1) {
                line += "\n";
            }

            file << line;
        }

        file.close();
    }

    void DblToCsv(std::vector<double> vecin, std::string filename) {

        // Setup
        int nj = vecin.size();
        std::ofstream file(filename);

        // For each row, construct line and print


        std::string line = "";

        for (int j = 0; j < nj; j++) {
            line += std::to_string(vecin[j]);

            if (j < nj - 1) {
                line += ",";
            }
        }

        file << line;


        file.close();
    }

    void IntToCsv(std::vector<std::vector<int>> matin, std::string filename) {

        // Setup
        int ni = matin.size();
        int nj = matin[0].size();
        std::ofstream file(filename);

        // For each row, construct line and print
        for (int i = 0; i < ni; i++) {

            std::string line = "";

            for (int j = 0; j < nj; j++) {
                line += std::to_string(matin[i][j]);

                if (j < nj - 1) {
                    line += ",";
                }
            }

            if (i < ni - 1) {
                line += "\n";
            }

            file << line;
        }

        file.close();

    }

    void AddToLog(std::string str, int level, bool skipLineStart = false, bool skipNewLine = false) {

        // Level 0, nothing
        // Level 1, alerts only
        // Level 2, model progress

        std::string lineStart;

        if (!skipLineStart) {
            switch (level) {
            case 0: lineStart = " !!! "; break;
            case 1: lineStart = " >>> "; break;
            case 2: lineStart = "     "; break;
            }
            str = lineStart + str;
        }

        if (!skipNewLine) {
            str += "\n";
        }

        // Print in console
        std::cout << str;

        // Write to file
        if (writePath != "") {
            WriteLine(str, "log.txt", true);
        }

    }

    void WriteLine(std::string line, std::string fileName, bool append, bool isPath = false) {
        // Write line to any file

        std::string filePath;
        filePath = (isPath) ? fileName : writePath + fileName;
        std::ofstream file;
        if (!append) {
            file = std::ofstream(filePath);
        }
        else {
            file = std::ofstream(filePath, std::ios::app);
        }
        file << line;
    }
};

int main(int argc, char* argv[])
{
    ModelState model(argc, argv);
    model.InitializeLabels();
    model.DoIterations();

    return 0;
}
