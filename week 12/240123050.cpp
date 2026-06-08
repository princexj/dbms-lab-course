#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <tuple>
#include <algorithm>
#include <stdexcept>
#include <mysql/mysql.h>




using namespace std;

void executeQuery(MYSQL* conn, const string& query) {
    if (mysql_query(conn, query.c_str())) {
        cerr << "Error executing query: " << mysql_error(conn) << endl;
    }
}

vector<string> parseCSVLine(const string& line) {
    vector<string> tokens;
    stringstream ss(line);
    string token;
    while (getline(ss, token, ',')) {
        tokens.push_back(token);
    }
    return tokens;
}


string normalizeMSQ(const string& ans) {
    vector<string> parts;
    stringstream ss(ans);
    string part;
    while (getline(ss, part, ';')) {
        parts.push_back(part);
    }
    sort(parts.begin(), parts.end());
    string result = "";
    for (int i = 0; i < (int)parts.size(); i++) {
        if (i > 0) result += ";";
        result += parts[i];
    }
    return result;
}


bool checkNAT(const string& correct, const string& candidate_ans) {
    double lo, hi, cand_val;
    if (sscanf(correct.c_str(), "%lf to %lf", &lo, &hi) == 2) {
        try {
            cand_val = stod(candidate_ans);
            return (cand_val >= lo && cand_val <= hi);
        } catch (...) {
            return false;
        }
    }
    return false;
}

int main() {

    MYSQL* conn = mysql_init(NULL);
    if (conn == NULL) {
        cerr << "mysql_init() failed\n";
        return 1;
    }

    if (mysql_real_connect(conn, "localhost", "root", "root@123", NULL, 0, NULL, 0) == NULL) {
        cerr << "mysql_real_connect() failed: " << mysql_error(conn) << endl;
        mysql_close(conn);
        return 1;
    }

    
    executeQuery(conn, "DROP DATABASE IF EXISTS week12");
    executeQuery(conn, "CREATE DATABASE week12");
    executeQuery(conn, "USE week12");


    string createSolutions = "CREATE TABLE solutions ("
                             "q_num INT, "
                             "subject VARCHAR(10), "
                             "q_type VARCHAR(10), "
                             "correct_answer VARCHAR(100), "
                             "max_marks INT, "
                             "PRIMARY KEY(q_num, subject))";
    executeQuery(conn, createSolutions);


    string createResponses = "CREATE TABLE candidate_responses (reg_no VARCHAR(20) PRIMARY KEY";
    for (int i = 1; i <= 16; ++i) createResponses += ", math_" + to_string(i) + " VARCHAR(20)";
    for (int i = 1; i <= 16; ++i) createResponses += ", phy_"  + to_string(i) + " VARCHAR(20)";
    for (int i = 1; i <= 16; ++i) createResponses += ", chy_"  + to_string(i) + " VARCHAR(20)";
    createResponses += ")";
    executeQuery(conn, createResponses);


    string createScores = "CREATE TABLE candidate_scores ("
                          "reg_no VARCHAR(20) PRIMARY KEY, "
                          "maths_marks INT, "
                          "phy_marks INT, "
                          "chy_marks INT, "
                          "total_marks INT)";
    executeQuery(conn, createScores);

    
    
    
    ifstream keyFile("key.csv");
    string line;
    while (getline(keyFile, line)) {
        vector<string> data = parseCSVLine(line);
        if (data.size() >= 5) {
            string query = "INSERT INTO solutions VALUES (" +
                           data[0] + ", '" + data[1] + "', '" +
                           data[2] + "', '" + data[3] + "', " + data[4] + ")";
            executeQuery(conn, query);
        }
    }
    keyFile.close();


    executeQuery(conn, "SELECT COUNT(*) FROM solutions");
    MYSQL_RES* res = mysql_store_result(conn);
    MYSQL_ROW row = mysql_fetch_row(res);
    cout << "Total answer keys loaded: " << row[0] << " (Expected: 48)\n";
    mysql_free_result(res);

    
    ifstream responseFile("jee_candidates_1000.csv");
    while (getline(responseFile, line)) {
        vector<string> data = parseCSVLine(line);
        if (data.size() >= 49) {
            string query = "INSERT INTO candidate_responses VALUES ('" + data[0] + "'";
            for (int i = 1; i <= 48; ++i) {
                query += ", '" + data[i] + "'";
            }
            query += ")";
            executeQuery(conn, query);
        }
    }
    responseFile.close();


    executeQuery(conn, "SELECT COUNT(*) FROM candidate_responses");
    res = mysql_store_result(conn);
    row = mysql_fetch_row(res);
    cout << "Total candidates loaded: " << row[0] << " (Expected: 1000)\n\n";
    mysql_free_result(res);


    executeQuery(conn, "SELECT COUNT(*) - 1 FROM information_schema.columns "
                       "WHERE table_schema = 'week12' AND table_name = 'candidate_responses'");
    res = mysql_store_result(conn);
    row = mysql_fetch_row(res);
    cout << "Responses per candidate: " << row[0] << " (Expected: 48)\n";
    mysql_free_result(res);

    
    
    
    
    executeQuery(conn, "SELECT q_num, q_type, correct_answer, max_marks FROM solutions "
                       "ORDER BY FIELD(subject, 'MATHS', 'PHY', 'CHY'), q_num");
    res = mysql_store_result(conn);




    vector<tuple<string, string, int>> keys(48);
    int idx = 0;
    while ((row = mysql_fetch_row(res))) {
        keys[idx++] = make_tuple(string(row[1]), string(row[2]), stoi(row[3]));
    }
    mysql_free_result(res);



    executeQuery(conn, "SELECT * FROM candidate_responses");
    res = mysql_store_result(conn);
    while ((row = mysql_fetch_row(res))) {
        string reg_no = row[0];
        int maths_marks = 0, phy_marks = 0, chy_marks = 0;

        for (int i = 1; i <= 48; ++i) {
            string candidate_ans = row[i] ? row[i] : "";
            string q_type  = get<0>(keys[i-1]);
            string correct = get<1>(keys[i-1]);
            int    marks   = get<2>(keys[i-1]);

            bool is_correct = false;

            if (q_type == "MCQ") {
                is_correct = (candidate_ans == correct);
            } else if (q_type == "MSQ") {
                is_correct = (normalizeMSQ(candidate_ans) == normalizeMSQ(correct));
            } else if (q_type == "NAT") {
                is_correct = checkNAT(correct, candidate_ans);
            }

            if (is_correct) {
                if (i <= 16)      maths_marks += marks;
                else if (i <= 32) phy_marks   += marks;
                else              chy_marks   += marks;
            }
        }

        int total_marks = maths_marks + phy_marks + chy_marks;

        string insertScore = "INSERT INTO candidate_scores VALUES ('" + reg_no + "', " +
                             to_string(maths_marks) + ", " + to_string(phy_marks) + ", " +
                             to_string(chy_marks)   + ", " + to_string(total_marks) + ")";
        executeQuery(conn, insertScore);
    }
    mysql_free_result(res);




    cout << "--- Candidate Scores ---\n";
    executeQuery(conn, "SELECT reg_no, maths_marks, phy_marks, chy_marks, total_marks "
                       "FROM candidate_scores ORDER BY total_marks DESC");
    res = mysql_store_result(conn);
    while ((row = mysql_fetch_row(res))) {
        cout << row[0] << ","
             << row[1] << ","
             << row[2] << ","
             << row[3] << ","
             << row[4] << "\n";
    }
    mysql_free_result(res);

    mysql_close(conn);
    return 0;
}
