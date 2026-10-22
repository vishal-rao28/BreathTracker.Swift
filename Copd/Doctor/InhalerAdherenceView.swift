import SwiftUI

// MARK: - Inhaler Adherence View (Doctor Side)
struct InhalerAdherenceView: View {
    @Environment(\.dismiss) private var dismiss
    let patientId: String
    let patientName: String

    @State private var appeared = false
    @State private var fetchedTakenDates: Set<String> = [] // NEW: Store dates from server

    // Generate months starting from the current month back to the specific month they first took a dose
    private var months: [Date] {
        let cal = Calendar.current
        let today = Date()

        // 1. Scan backwards (up to 365 days) to find the EARLIEST day they took an inhaler dose
        var oldestOffsetFound = 0
        for offset in (1...365).reversed() {
            if let checkDate = cal.date(byAdding: .day, value: -offset, to: today), isTaken(on: checkDate) {
                oldestOffsetFound = offset
                break
            }
        }

        // 2. Get the month bounds for the earliest date and today
        guard let earliestDate = cal.date(byAdding: .day, value: -oldestOffsetFound, to: today),
              let startOfEarliestMonth = cal.date(from: cal.dateComponents([.year, .month], from: earliestDate)),
              let startOfCurrentMonth = cal.date(from: cal.dateComponents([.year, .month], from: today)) else {
            return [today]
        }

        // 3. Generate the sequence of months from Now down to Earliest Time
        var result: [Date] = []
        var iteratorDate = startOfCurrentMonth
        while iteratorDate >= startOfEarliestMonth {
            result.append(iteratorDate)
            guard let prev = cal.date(byAdding: .month, value: -1, to: iteratorDate) else { break }
            iteratorDate = prev
        }

        return result.isEmpty ? [today] : result
    }

    private func isTaken(on date: Date) -> Bool {
        // 1. Check network data
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let stringDate = fmt.string(from: date)
        if fetchedTakenDates.contains(stringDate) {
            return true
        }
        
        // 2. Fallback to Local Device Memory (UserDefaults) in case Backend fails
        let localKey = "inhaler_taken_\(patientId)_\(DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none))"
        return UserDefaults.standard.bool(forKey: localKey)
    }

    // Month-based simplified metrics requested by doctor
    private var daysInCurrentMonth: Int {
        let cal = Calendar.current
        let today = Date()
        guard let range = cal.range(of: .day, in: .month, for: today) else { return 30 }
        return range.count
    }

    private var takenThisMonthCount: Int {
        let cal = Calendar.current
        let today = Date()
        guard let startOfMonth = cal.date(from: cal.dateComponents([.year, .month], from: today)),
              let range = cal.range(of: .day, in: .month, for: today) else { return 0 }
        
        var count = 0
        for dayOffset in 0..<range.count {
            if let d = cal.date(byAdding: .day, value: dayOffset, to: startOfMonth) {
                if isTaken(on: d) { count += 1 }
            }
        }
        return count
    }

    // The earliest date the patient ever took a dose
    private var firstDoseDate: Date? {
        let cal = Calendar.current
        let today = Date()
        for offset in (0...365).reversed() { // Look back up to a year
            if let d = cal.date(byAdding: .day, value: -offset, to: today), isTaken(on: d) {
                return cal.startOfDay(for: d)
            }
        }
        return nil
    }

    // Number of days passed so far in the current month
    private var activeDaysThisMonth: Int {
        let cal = Calendar.current
        let today = Date()
        let currentDay = cal.component(.day, from: today) // Today's date integer
        return currentDay
    }

    private var missedThisMonthCount: Int {
        // Calculate misses ONLY for days they were actively using the app this month
        return max(0, activeDaysThisMonth - takenThisMonthCount)
    }

    var body: some View {
        ZStack {
            Color.btBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    BTBackButton(action: { dismiss() })
                    Spacer()
                    Text("Inhaler Adherence")
                        .font(.btHeadline)
                        .foregroundColor(.btTextPrimary)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Spacing.xl) {

                        // Patient hero card
                        HStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient.btDoctorGradient)
                                    .frame(width: 56, height: 56)
                                let initials = patientName.split(separator: " ").prefix(2)
                                    .map { String($0.prefix(1)) }.joined().uppercased()
                                Text(initials.isEmpty ? "?" : initials)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(patientName)
                                    .font(.btTitle)
                                    .foregroundColor(.btTextPrimary)
                                Text(months.count == 1 ? "Inhaler History — Current Month" : "Inhaler History — Since First Dose")
                                    .font(.btCaption)
                                    .foregroundColor(.btTextSecond)
                            }
                            Spacer()
                        }
                        .padding(Spacing.lg)
                        .background(Color.btSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .btCardShadow()
                        .padding(.horizontal, Spacing.lg)
                        .padding(.top, Spacing.sm)
                        .opacity(appeared ? 1 : 0)

                        // Simplified Monthly Stat Badge (Only 1 Block)
                        StatBadge(
                            value: "\(takenThisMonthCount)/\(daysInCurrentMonth)",
                            label: "Total Taken This Month",
                            icon: "calendar",
                            color: .btDoctorPrimary
                        )
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)

                        // Only show the missed status if they actually missed days
                        let missed = missedThisMonthCount
                        if missed > 0 {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.btAccentOrange)
                                Text("Patient missed \(missed) \(missed == 1 ? "day" : "days") so far this month")
                                    .font(.btBodyMedium)
                                    .foregroundColor(.btAccentOrange)
                            }
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.btAccentOrange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal, Spacing.lg)
                            .opacity(appeared ? 1 : 0)
                        }

                        // Legend
                        HStack(spacing: Spacing.lg) {
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.btAccentGreen)
                                    .frame(width: 16, height: 16)
                                Text("Taken").font(.btCaption).foregroundColor(.btTextSecond)
                            }
                            HStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.btBorder)
                                    .frame(width: 16, height: 16)
                                Text("Not Taken / No Data").font(.btCaption).foregroundColor(.btTextSecond)
                            }
                        }
                        .padding(.horizontal, Spacing.lg)
                        .opacity(appeared ? 1 : 0)

                        // Monthly calendars
                        VStack(spacing: Spacing.xl) {
                            ForEach(Array(months.enumerated()), id: \.offset) { index, monthDate in
                                MonthCalendarCard(
                                    monthDate: monthDate,
                                    patientId: patientId,
                                    isTakenFn: isTaken
                                )
                                .padding(.horizontal, Spacing.lg)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 20)
                                .animation(.spring().delay(0.1 + Double(index) * 0.04), value: appeared)
                            }
                        }

                        Spacer(minLength: 60)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchInhalerHistory()
        }
    }
    
    // NEW: Function to ask the PHP backend for reality
    private func fetchInhalerHistory() {
        guard let url = APIConfig.getURL(for: "get_inhaler_history.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["patient_id": patientId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let datesArray = json["taken_dates"] as? [String] {
                    self.fetchedTakenDates = Set(datesArray)
                }
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appeared = true
                }
            }
        }.resume()
    }
}

// MARK: - Premium Stat Badge
private struct StatBadge: View {
    let value: String
    let label: String
    let icon: String // Dynamic icon
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            // Floating Top Icon
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(color)
            }
            
            // Stats
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.btTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.btTextSecond)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 4)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(color.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Month Calendar Card
private struct MonthCalendarCard: View {
    let monthDate: Date
    let patientId: String
    let isTakenFn: (Date) -> Bool

    private var monthName: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM yyyy"
        return fmt.string(from: monthDate)
    }

    private var daysInMonth: [Date?] {
        let cal = Calendar.current
        guard
            let range = cal.range(of: .day, in: .month, for: monthDate),
            let firstDay = cal.date(from: cal.dateComponents([.year, .month], from: monthDate))
        else { return [] }

        let weekdayOffset = (cal.component(.weekday, from: firstDay) - cal.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: weekdayOffset)
        for day in range {
            days.append(cal.date(byAdding: .day, value: day - 1, to: firstDay))
        }
        return days
    }

    private var takenThisMonth: Int {
        daysInMonth.compactMap { $0 }.filter { isTakenFn($0) }.count
    }

    private var totalDays: Int { daysInMonth.compactMap { $0 }.count }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Month header
            HStack {
                Text(monthName)
                    .font(.btHeadline)
                    .foregroundColor(.btTextPrimary)
                Spacer()
                Text("\(takenThisMonth)/\(totalDays) taken")
                    .font(.btCaption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(takenThisMonth > 0 ? Color.btAccentGreen.opacity(0.12) : Color.btBorder.opacity(0.5))
                    .foregroundColor(takenThisMonth > 0 ? .btAccentGreen : .btTextTertiary)
                    .clipShape(Capsule())
            }

            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays.indices, id: \.self) { i in
                    Text(weekdays[i])
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.btTextSecond)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth.indices, id: \.self) { i in
                    if let date = daysInMonth[i] {
                        DayCell(date: date, isTaken: isTakenFn(date))
                    } else {
                        Color.clear.frame(height: 34)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.btSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .btCardShadow()
    }
}

// MARK: - Day Cell
private struct DayCell: View {
    let date: Date
    let isTaken: Bool

    private var dayNumber: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "d"
        return fmt.string(from: date)
    }

    private var isFuture: Bool { date > Date() }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isFuture
                        ? Color.btBorder.opacity(0.12)
                        : isTaken
                            ? Color.btAccentGreen.opacity(0.22)
                            : Color.btBorder.opacity(0.45)
                )
                .frame(height: 34)

            if isTaken {
                VStack(spacing: 1) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.btAccentGreen)
                    Text(dayNumber)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.btAccentGreen)
                }
            } else if isFuture {
                Text(dayNumber)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.btTextTertiary.opacity(0.5))
            } else {
                Text(dayNumber)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.btTextPrimary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        InhalerAdherenceView(patientId: "dummy_123", patientName: "John Anderson")
    }
}
