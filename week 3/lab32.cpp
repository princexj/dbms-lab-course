#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <sstream>
#include <algorithm>
#include <iomanip>
#include <map>

using namespace std;


struct Date {
    int day, month, year;
};

struct Time {
    int hour, minute;
};

struct DateTime {
    Date d;
    Time t;
};

struct FlightInfo {
    int flight_id;
    string origin;
    string dest;
    DateTime scheduled;
    DateTime actual;
    int delay_minutes;
};


DateTime parseDateTime(const string& str) {
    DateTime dt;
    char dash, colon;
    stringstream ss(str);
    ss >> dt.d.year >> dash >> dt.d.month >> dash >> dt.d.day 
       >> dt.t.hour >> colon >> dt.t.minute;
    return dt;
}


int computeTotalMinutes(const DateTime& dt) {
    return (dt.d.year * 525600) + (dt.d.month * 43200) + 
           (dt.d.day * 1440) + (dt.t.hour * 60) + dt.t.minute;
}

vector<FlightInfo> readFlights(const string& fname) {
    vector<FlightInfo> flights;
    ifstream file(fname);
    
    if (!file.is_open()) {
        cerr << "Error: Could not open " << fname << endl;
        return flights;
    }

    string line, header;
    getline(file, header); 

    while (getline(file, line)) {
        stringstream ss(line);
        string segment;
        vector<string> parts;

       
        while (getline(ss, segment, ',')) {
            parts.push_back(segment);
        }

        if (parts.size() >= 5) {
            FlightInfo f;
            f.flight_id = stoi(parts[0]);
            f.origin = parts[1];
            f.dest = parts[2];
            f.scheduled = parseDateTime(parts[3]);
            f.actual = parseDateTime(parts[4]);
            f.delay_minutes = computeTotalMinutes(f.actual) - computeTotalMinutes(f.scheduled);
            flights.push_back(f);
        }
    }
    return flights;
}

void writeDelayFile(const vector<FlightInfo>& flights) {
    ofstream out("delay-computation.csv");
    for (const auto& f : flights) {
        out << f.flight_id << "," << f.origin << "," << f.dest << "," <<f.delay_minutes << "\n";
    }
}

void writeSortedFile(vector<FlightInfo> flights) {
    
    sort(flights.begin(), flights.end(), [](const FlightInfo& a, const FlightInfo& b) {
        return a.delay_minutes > b.delay_minutes; 
    });

    ofstream out("sorted-delay-info.csv");
    for (const auto& f : flights) {
        out << f.flight_id << "," << f.delay_minutes << "\n";
    }
}

void computeAverages(const vector<FlightInfo>& flights) {
    map<string, pair<int, int>> stats; 

    for (const auto& f : flights) {
        stats[f.origin].first += f.delay_minutes;
        stats[f.origin].second++;
    }

    ofstream out("flight-delays-by-origin.csv");
    out << fixed << setprecision(2);
    for (auto const& [origin, data] : stats) {
        double avg = static_cast<double>(data.first) / data.second;
        out << origin << "," << avg << "\n";
    }
}

void findMostDelayedRoute(const vector<FlightInfo>& flights) {
    map<pair<string, string>, pair<int, int>> route_stats;

    for (const auto& f : flights) {
        route_stats[{f.origin, f.dest}].first += f.delay_minutes;
        route_stats[{f.origin, f.dest}].second++;
    }

    pair<string, string> best_route;
    double max_avg = -999999.0;

    for (auto const& [route, data] : route_stats) {
        double avg = static_cast<double>(data.first) / data.second;
        if (avg > max_avg) {
            max_avg = avg;
            best_route = route;
        }
    }

    ofstream out("most-delayed-route.csv");
    out << fixed << setprecision(2);
    out << best_route.first << "," << best_route.second << "," << max_avg << "\n";
}

int main() {
    vector<FlightInfo> flights = readFlights("flights.csv");

    if (flights.empty()) return 1;

    writeDelayFile(flights);
    writeSortedFile(flights);
    computeAverages(flights);
    findMostDelayedRoute(flights);


    return 0;
}
