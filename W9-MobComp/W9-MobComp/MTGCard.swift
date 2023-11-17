//
//  MTGCard.swift
//  W9-MobComp
//
//  Created by MacBook Pro on 10/11/23.
//

// MTGCard.swift
import Foundation
struct LegalitiesList: Codable {
    var standard: String
    var future: String
    var historic: String
    var gladiator: String
    var pioneer: String
    var explorer: String
    var modern: String
    var legacy: String
    var pauper: String
    var vintage: String
    var penny: String
    var commander: String
    var oathbreaker: String
    var brawl: String
    var historicbrawl: String
    var alchemy: String
    var paupercommander: String
    var duel: String
    var oldschool: String
    var premodern: String
    var predh: String
}
struct MTGCard: Codable, Identifiable {
    var id: UUID
    var name: String
    var type_line: String
    var oracle_text: String
    var image_uris: ImageURIs?
    var legalities: LegalitiesList
    var prices: PricesList?

    struct ImageURIs: Codable {
        var small: String?
        var normal: String?
        var large: String?
        var art_crop: String?

    }
    struct PricesList: Codable {
            var usd: String?
            var usd_foil: String?
            var usd_etched: String?
            var eur: String?
            var eur_foil: String?
            var tix: String?
        func dictionaryRepresentation() -> [String: String] {
                    var dictionary = [String: String]()

                    if let usd = usd { dictionary["USD"] = usd }
                    if let usd_foil = usd_foil { dictionary["USD Foil"] = usd_foil }
                    if let usd_etched = usd_etched { dictionary["USD Etched"] = usd_etched }
                    if let eur = eur { dictionary["EUR"] = eur }
                    if let eur_foil = eur_foil { dictionary["EUR Foil"] = eur_foil }
                    if let tix = tix { dictionary["TIX"] = tix }

                    return dictionary
                }
        }
    
}

struct MTGCardList: Codable {
    var object: String
    var total_cards: Int
    var has_more: Bool
    var data: [MTGCard]
}

