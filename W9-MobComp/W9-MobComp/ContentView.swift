import SwiftUI
struct LegalitiesPair: Hashable {
    let value: String
    let key: String
}
struct MTGCardView: View {
    var mtgCards: [MTGCard]
    @State private var currentIndex: Int
    @State private var selectedButton: String?
    @State private var isArtCrop = true
    @State private var isImagePopupVisible = false

    
    init(mtgCards: [MTGCard], currentIndex: Int) {
        self.mtgCards = mtgCards
        self._currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        VStack {
            ScrollView {
                AsyncImage(url: URL(string: mtgCards[currentIndex].image_uris?.art_crop ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.red)
                    case .empty:
                        ProgressView()
                    @unknown default:
                        ProgressView()
                    }
                    // judul yg di detail card
                    Text(mtgCards[currentIndex].name)
                        .font(.title)
                        .padding()
                    VStack(alignment: .leading) {
                        Text("\(mtgCards[currentIndex].type_line)") //deskripsi kartu
                            .fontWeight(.bold)
                        Text("(\(mtgCards[currentIndex].oracle_text))")
                        HStack {
                            Spacer()
                            
                            // Button u/ Versions
                            Button("Versions") {
                                selectedButton = "Versions"
                            }
                            .padding(.horizontal, 45.0)
                            .padding(.vertical, 15.0)
                            .frame(maxHeight: .infinity)
                            .background(
                                Capsule()
                                .fill(selectedButton == "Versions" ? Color.red : Color.clear) // Change background color to red if selected
                                .overlay(
                                    Capsule()
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            )
                            .foregroundColor(selectedButton == "Versions" ? .white : .black)
                            
                            
                            // Button u/ Rulings
                            Button("Rulings") {
                                selectedButton = "Rulings"
                            }
                            .padding(.horizontal, 50.0)
                            .frame(maxHeight: .infinity)
                            .background(
                                Capsule()
                                    .fill(selectedButton == "Rulings" ? Color.red : Color.clear) // Change background color to red if selected
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(selectedButton == "Rulings" ? .white : .black)
                            
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        
                        
                        // cek yg di klik rulings/version
                        if selectedButton == "Rulings" {
                            Text("LEGALITIES")
                                .fontWeight(.bold)
                                .foregroundColor(Color.red)
                            
                            LazyVGrid(columns: [GridItem(), GridItem()]) {
                                ForEach(Array(Mirror(reflecting: mtgCards[currentIndex].legalities).children), id: \.label) { child in
                                    if let label = child.label, let value = child.value as? String {
                                        let displayValue = value == "not_legal" ? "not legal" : value
                                        LegalitiesItem(value: displayValue, key: label.capitalized)
                                    }
                                }
                            }
                            .padding()
                        }else if selectedButton == "Versions" {
                            Text("PRICES")
                                .fontWeight(.bold)
                                .foregroundColor(Color.red)
                            
                            ForEach(Array(Mirror(reflecting: mtgCards[currentIndex].prices ?? [:]).children), id: \.label) { child in
                                if let label = child.label, let value = child.value as? String {
                                    let formattedKey = label.replacingOccurrences(of: "_", with: " ").capitalized
                                    PriceItem(value: value, key: formattedKey)
                                }
                            }
                            
                            .padding()
                        }
                    }
                    HStack {
                        Button("Previous") {
                            navigateToPreviousCard()
                        }
                        .padding()
                        .disabled(currentIndex == 0) // Disable the button if it's the first card
                        
                        Spacer()
                        
                        Button("Next") {
                            navigateToNextCard()
                        }
                        .padding()
                        .disabled(currentIndex == mtgCards.count - 1) // Disable the button if it's the last card
                    }
                }
                .onTapGesture {
                    isImagePopupVisible.toggle()
                }
                .padding()
                .sheet(isPresented: $isImagePopupVisible) {
                    // Display the large image in a popup
                    if let largeImageUrl = URL(string: mtgCards[currentIndex].image_uris?.large ?? "") {
                        AsyncImage(url: largeImageUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            case .failure:
                                Text("Failed to load image")
                            case .empty:
                                ProgressView()
                            @unknown default:
                                ProgressView()
                            }
                        }
                        .padding()
                    }
                }
                
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        let swipeThreshold: CGFloat = 50
                        if gesture.translation.width > swipeThreshold {
                            navigateToPreviousCard()
                        } else if gesture.translation.width < -swipeThreshold {
                            navigateToNextCard()
                        }
                    }
            )
        }
        
        

    }
    private func navigateToNextCard() {
        if currentIndex < mtgCards.count - 1 {
            currentIndex += 1
        }
        selectedButton = nil
    }
    
    // Function to navigate to the previous card
    private func navigateToPreviousCard() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
        selectedButton = nil
    }
}


extension MTGCardView: Identifiable {
    var id: UUID { mtgCards[currentIndex].id }
}

struct PriceItem: View {
    var value: String
    var key: String

    var body: some View {
        HStack {
            Text("\(key):")
            Text(value)
                .fontWeight(.bold)
        }
    }
}

struct LegalitiesItem: View {
    var value: String
    var key: String
    
    var body: some View {
        HStack {
            Text(value)
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .frame(width: 70)
                .background(value == "legal" ? Color.green : Color.gray)
                .cornerRadius(8)
                .font(.system(size: 14))
                .padding(.vertical, 10)

            
            Text(key)
                .padding(.trailing, 5.0)
                .frame(width: 90)
                .foregroundColor(.black)
                .font(.system(size: 14))
            
        }
      
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                            .padding(.trailing, 4)
                    }
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
}

struct ContentView: View {
    @State private var mtgCards: [MTGCard] = []
    @State private var searchText: String = ""
    @State private var isSortingAscending = true

    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var filteredCards: [MTGCard] {
        if searchText.isEmpty {
            return mtgCards
        } else {
            return mtgCards.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    var sortedCards: [MTGCard] {
        return filteredCards.sorted {
            isSortingAscending ? $0.name < $1.name : $0.name > $1.name
        }
    }

    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    HStack {
                       SearchBar(searchText: $searchText)
                       
                       // sorting button
                       Button(action: {
                           isSortingAscending.toggle()
                       }) {
                           Image(systemName: isSortingAscending ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                               .foregroundColor(.blue)
                       }
                       .padding(.trailing, 10)
                   }

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(sortedCards.indices, id: \.self) { index in
                            NavigationLink(destination: MTGCardView(mtgCards: sortedCards, currentIndex: index)) {
                                CardImageView(card: sortedCards[index])
                                    .frame(height: 220)
                            }
                        }
                    }

                    .padding()
                }
                .onAppear {
                    // Load data from a JSON file
                    if let data = loadJSON() {
                        do {
                            let decoder = JSONDecoder()
                            let cards = try decoder.decode(MTGCardList.self, from: data)
                            mtgCards = cards.data
                        } catch {
                            print("Error decoding JSON: \(error)")
                        }
                    }
                }
                .navigationBarTitle("MTG Cards")
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }

            Text("Collection")
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Collection")
                }

            Text("Decks")
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Decks")
                }

            Text("Scan")
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                }

        }
        .accentColor(.black)
    }

    
    // Function to load data from a JSON file
    func loadJSON() -> Data? {
        if let path = Bundle.main.path(forResource: "WOT-Scryfall", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardImageView: View {
    var card: MTGCard
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: card.image_uris?.large ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                case .empty:
                    ProgressView()
                @unknown default:
                    ProgressView()
                }
            }
            
            Text(card.name)
                .font(.system(size: 12))
                .padding(.top, 8)

        }
    }
}

