#include<bits/stdc++.h>
#include<string>
using namespace std;
class ATM{
    public:
    string bankname;
    double latitude;
    double longitude;
    string atmid;
};

void readCSV(const string& filename,vector<ATM> &v) {
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Error opening " << filename << endl;
        return;
    }

    string line;
    while (getline(file, line)) {
        if (line.empty()) continue;
        stringstream ss(line);
        string token;
        vector<string> tokens;

        while (getline(ss, token, ','))
            tokens.push_back(token);

        if (tokens.size() == 4) {
            ATM temp;
            temp.bankname = tokens[0];
            temp.latitude = stod(tokens[1]);
            temp.longitude = stod(tokens[2]);
            temp.atmid = tokens[3];
            v.push_back(temp);

            
        }
    }
}

double dist(ATM val1,ATM val2)
{
    return 111.0*sqrt( (val1.latitude-val2.latitude)*(val1.latitude-val2.latitude)   +  (val1.longitude-val2.longitude)*(val1.longitude-val2.longitude)    );
}

void Bsort(ATM val,vector<ATM> data)
{
    
    int n=data.size();
    vector<ATM> temp(n);
    for(int i=0;i<n;i++)
    {
        temp[i]=data[i];
    }

    bool swapped=false;

    for (int i = 0; i < n - 1; i++) {
        swapped = false;
        
        
        for (int j = 0; j < n - i - 1; j++) {
            if (dist(temp[j],val) > dist(temp[j + 1],val) ){
                
                swap(temp[j], temp[j + 1]);
                swapped = true;
            }else if(dist(temp[j],val) == dist(temp[j + 1],val)   &&   temp[j].atmid>temp[j+1].atmid)
            {
                swap(temp[j],temp[j+1]);
                swapped = true;
            }
        }

        
        if (!swapped)
            break;
    }

    int count=0;
    cout<<"Nearby "<<val.bankname<<" ATMs within 1 km of location"<<" ( "<< setprecision(7)<<val.latitude <<" , "<< setprecision(7) <<val.longitude<<" ) :" <<endl;
    cout<<endl;
    for(int i=0;i<n;i++)
    {
        if(dist(temp[i],val) <= 1.000001 && temp[i].bankname==val.bankname)
        {
            cout<<temp[i].atmid<< " dist : "<< setprecision(1)<<dist(temp[i],val);
            cout<<endl;
            count++;
        }
        if(dist(temp[i],val) > 1.000001)
        {
            if(count==0)
            {
                cout<<"NO ATM is found within 1 km range";
            }
            break;
        }
    }


}



int main()
{
    vector<ATM> data;
    readCSV("ATMs.csv",data);
    vector<ATM> query;
    readCSV("query.csv",query);

    for(int i=0;i<5;i++)
    {
        Bsort(query[i],data);
        cout<<endl;
        cout<<endl;
    }


    
    
    return 0;
}
