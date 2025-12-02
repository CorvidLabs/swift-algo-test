import Foundation

/// Pre-built transaction scenarios for common test cases.
public enum TransactionScenarios {
    /// Creates a simple payment transaction.
    public static func simplePayment(
        from sender: FundedAccount,
        to receiver: FundedAccount,
        amount: UInt64 = 1_000_000
    ) throws -> Transaction {
        try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(amount)
            .build()
    }

    /// Creates a payment with a note.
    public static func paymentWithNote(
        from sender: FundedAccount,
        to receiver: FundedAccount,
        amount: UInt64,
        note: String
    ) throws -> Transaction {
        try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(amount)
            .note(note)
            .build()
    }

    /// Creates a minimum balance payment.
    public static func minimumPayment(
        from sender: FundedAccount,
        to receiver: FundedAccount
    ) throws -> Transaction {
        try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(100_000) // 0.1 ALGO
            .build()
    }

    /// Creates a large payment transaction.
    public static func largePayment(
        from sender: FundedAccount,
        to receiver: FundedAccount
    ) throws -> Transaction {
        try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(100_000_000_000) // 100,000 ALGO
            .build()
    }

    /// Creates a zero-amount transaction (for note-only transactions).
    public static func zeroPayment(
        from sender: FundedAccount,
        to receiver: FundedAccount,
        note: String
    ) throws -> Transaction {
        try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(0)
            .note(note)
            .build()
    }

    /// Creates a high-fee transaction.
    public static func highFeePayment(
        from sender: FundedAccount,
        to receiver: FundedAccount,
        amount: UInt64,
        fee: UInt64 = 10_000
    ) throws -> Transaction {
        try TestTransactionBuilder
            .payment(from: sender)
            .to(receiver)
            .amount(amount)
            .fee(fee)
            .build()
    }

    /// Creates a batch of payments from one sender to multiple receivers.
    public static func batchPayments(
        from sender: FundedAccount,
        to receivers: [FundedAccount],
        amount: UInt64
    ) throws -> [Transaction] {
        try receivers.map { receiver in
            try simplePayment(from: sender, to: receiver, amount: amount)
        }
    }

    /// Creates a circular payment scenario (A -> B -> C -> A).
    public static func circularPayments(
        accounts: [FundedAccount],
        amount: UInt64
    ) throws -> [Transaction] {
        guard accounts.count >= 2 else {
            throw AlgoTestError.transactionBuildFailed("Need at least 2 accounts for circular payments")
        }

        var transactions: [Transaction] = []

        for (index, account) in accounts.enumerated() {
            let nextIndex = (index + 1) % accounts.count
            let nextAccount = accounts[nextIndex]

            transactions.append(
                try simplePayment(from: account, to: nextAccount, amount: amount)
            )
        }

        return transactions
    }
}
