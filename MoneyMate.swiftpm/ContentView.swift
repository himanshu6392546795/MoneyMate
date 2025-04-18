import SwiftUI
struct ContentView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            

            NavigationView {
                VStack(spacing: 20) {
                    Text("Personal Finance Manager")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    NavigationLink(destination: ExpenseView()) {
                        DashboardCard(title: "My Expenses", icon: "dollarsign.circle", color: .blue)
                    }
                    
                    NavigationLink(destination: LoanView()) {
                        DashboardCard(title: "Loans Given", icon: "arrow.forward.circle", color: .orange)
                    }
                    
                    Spacer()
                }
                .navigationTitle("Dashboard")
            }
        }
            .ignoresSafeArea()
    }
}

// MARK: - Dashboard Card
struct DashboardCard: View {
    var title: String
    var icon: String
    var color: Color
    
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(color)
                .padding()
            
            Text(title)
                .font(.title2)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}



// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let category: String
    let date: Date
}

// MARK: - Loan Model
struct Loan: Identifiable, Codable {
    let id: UUID
    var amount: Double
    let recipient: String
    let reason: String
    var repaymentHistory: [Repayment] = []
}

// MARK: - Repayment Model
struct Repayment: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let date: Date
}

// MARK: - Expense Management
struct ExpenseView: View {
    @State private var expenses: [Expense] = []
    @State private var newExpenseAmount: String = ""
    @State private var selectedCategory: String = "Food"
    @State private var customCategory: String = ""
    
    let categories = ["Food", "Transport", "Entertainment", "Shopping", "Other"]
    
    var groupedExpenses: [String: [Expense]] {
        Dictionary(grouping: expenses) { expense in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: expense.date)
        }
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(groupedExpenses.keys.sorted(), id: \ .self) { date in
                    Section(header: Text(date)) {
                        ForEach(groupedExpenses[date] ?? []) { expense in
                            HStack {
                                Text(expense.category)
                                Spacer()
                                Text("$\(String(format: "%.2f", expense.amount))")
                            }
                        }
                    }
                }
            }
            .onAppear(perform: loadExpenses)
            
            VStack {
                TextField("Expense Amount", text: $newExpenseAmount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categories, id: \ .self) { category in
                        Text(category)
                    }
                }
                .onChange(of: selectedCategory) { newValue in
                    if newValue != "Other" {
                        customCategory = ""
                    }
                }
                
                if selectedCategory == "Other" {
                    TextField("Specify Expense Type", text: $customCategory)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: addExpense) {
                    Text("Add Expense")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Expense Management")
    }
    
    func addExpense() {
        guard let amount = Double(newExpenseAmount) else { return }
        let category = selectedCategory == "Other" ? customCategory : selectedCategory
        let expense = Expense(id: UUID(), amount: amount, category: category, date: Date())
        expenses.append(expense)
        newExpenseAmount = ""
    }
    
    func loadExpenses() {
        // Load logic here
    }
}

// MARK: - Loan Management
struct LoanView: View {
    @State private var loans: [Loan] = []
    @State private var newLoanAmount: String = ""
    @State private var loanRecipient: String = ""
    @State private var loanReason: String = ""
    @State private var repaymentAmount: String = ""
    @State private var selectedLoanID: UUID? = nil
    @State private var showRepaymentAlert = false
    
    var body: some View {
        VStack {
            List {
                ForEach(loans) { loan in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(loan.recipient)
                                .font(.headline)
                            Spacer()
                            Text("$\(String(format: "%.2f", loan.amount))")
                                .font(.headline)
                        }
                        Text("Reason: \(loan.reason)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Button("Repayment") {
                            selectedLoanID = loan.id
                            showRepaymentAlert = true
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        if !loan.repaymentHistory.isEmpty {
                            Text("Repayment History:")
                                .font(.headline)
                            ForEach(loan.repaymentHistory) { repayment in
                                HStack {
                                    Text("$\(String(format: "%.2f", repayment.amount))")
                                    Spacer()
                                    Text(repayment.date, style: .date)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteLoan)
            }
            .onAppear(perform: loadLoans)
            
            VStack(spacing: 10) {
                            TextField("Loan Amount", text: $newLoanAmount)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
            
                            TextField("Friend's Name", text: $loanRecipient)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
            
                            TextField("Reason for Loan", text: $loanReason)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
            
                            Button(action: addLoan) {
                                Text("Add Loan")
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
            
                        Spacer()
        }
        .navigationTitle("Loan Management")
        .alert("Enter Repayment Amount", isPresented: $showRepaymentAlert) {
            TextField("Amount", text: $repaymentAmount)
                .keyboardType(.decimalPad)
            Button("OK", action: processRepayment)
            Button("Cancel", role: .cancel) { repaymentAmount = "" }
        }
    }
    func deleteLoan(at offsets: IndexSet) {
            loans.remove(atOffsets: offsets)
            saveLoans()
        }
    
    func processRepayment() {
        guard let selectedLoanID = selectedLoanID, let repayAmount = Double(repaymentAmount) else { return }
        if let index = loans.firstIndex(where: { $0.id == selectedLoanID }) {
            loans[index].amount -= repayAmount
            let repayment = Repayment(id: UUID(), amount: repayAmount, date: Date())
            loans[index].repaymentHistory.append(repayment)
            
            if loans[index].amount <= 0 {
                loans.remove(at: index)
            }
            saveLoans()
        }
        repaymentAmount = ""
    }
    
// Loan Persistence Methods
    func addLoan() {
           guard let amount = Double(newLoanAmount), !loanRecipient.isEmpty, !loanReason.isEmpty else { return }
           let loan = Loan(id: UUID(), amount: amount, recipient: loanRecipient, reason: loanReason)
           loans.append(loan)
           newLoanAmount = ""
           loanRecipient = ""
           loanReason = ""
           saveLoans()
       }
        func getFilePath(for fileName: String) -> URL {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return directory.appendingPathComponent(fileName)
        }
    
        func saveLoans() {
            let filePath = getFilePath(for: "loans.json")
            do {
                let data = try JSONEncoder().encode(loans)
                try data.write(to: filePath)
            } catch {
                print("Failed to save loans: \(error.localizedDescription)")
            }
        }
    
        func loadLoans() {
            let filePath = getFilePath(for: "loans.json")
            do {
                let data = try Data(contentsOf: filePath)
                loans = try JSONDecoder().decode([Loan].self, from: data)
            } catch {
                print("Failed to load loans: \(error.localizedDescription)")
            }
        }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
