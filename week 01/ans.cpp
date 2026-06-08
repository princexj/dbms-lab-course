#include <bits/stdc++.h>
using namespace std;

struct sailor {
    int sid;
    string sname;
    int rating;
    int age;
};

struct Node {
    sailor s;
    Node* left;
    Node* right;

    Node(sailor key) {
        s = key;
        left = right = nullptr;
    }
};

struct BST {
    Node* root = nullptr;

    Node* insert(Node* root, sailor key) {
        if (root == nullptr)
            return new Node(key);

        if (key.sid < root->s.sid)
            root->left = insert(root->left, key);
        else if (key.sid > root->s.sid)
            root->right = insert(root->right, key);

        return root;
    }

    bool find(Node* root, int x) {
        Node* temp = root;
        while (temp != nullptr) {
            if (temp->s.sid == x)
                return true;
            else if (x < temp->s.sid)
                temp = temp->left;
            else
                temp = temp->right;
        }
        return false;
    }

    void pre_order(Node* root) {
        if (root == nullptr) return;

        cout << root->s.sid << " "
             << root->s.sname << " "
             << root->s.rating << " "
             << root->s.age << endl;

        pre_order(root->left);
        pre_order(root->right);
    }

    void preorder_insert(Node* src) {
        if (!src) return;
        root = insert(root, src->s);
        preorder_insert(src->left);
        preorder_insert(src->right);
    }

    static BST Union(BST& A, BST& B) {
        BST C;
        C.preorder_insert(A.root);
        C.preorder_insert(B.root);
        return C;
    }

    static BST Intersection(BST& A, BST& B) {
        BST C;
        insert_if_common(C, A.root, B);
        return C;
    }

    static void insert_if_common(BST& C, Node* node, BST& B) {
        if (!node) return;
        if (B.find(B.root, node->s.sid))
            C.root = C.insert(C.root, node->s);

        insert_if_common(C, node->left, B);
        insert_if_common(C, node->right, B);
    }
};

void readCSV(const string& filename, BST& tree) {
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
            sailor temp;
            temp.sid = stoi(tokens[0]);
            temp.sname = tokens[1];
            temp.rating = stoi(tokens[2]);
            temp.age = stoi(tokens[3]);

            tree.root = tree.insert(tree.root, temp);
        }
    }
}

int main() {
    BST B1, B2;

    readCSV("s1.csv", B1);
    readCSV("s2.csv", B2);

    BST U = BST::Union(B1, B2);
    BST I = BST::Intersection(B1, B2);

    cout << "\n--- Union ---\n";
    U.pre_order(U.root);

    cout << "\n--- Intersection ---\n";
    I.pre_order(I.root);

    return 0;
}
