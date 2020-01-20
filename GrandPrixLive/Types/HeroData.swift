//
//  HeroData.swift
//  GrandPrixLive
//
//  Created by Markus Ort on 11.01.20.
//  Copyright © 2020 Markus Ort. All rights reserved.
//

import Foundation

enum contentUrls : String{
    case api = "f1tv-api.formula1.com/"
    case hero = "https://f1tv-api.formula1.com/api/sets/?fields_to_expand=items__content_url%2Citems__content_url__items__content_url&slug=home&fields=items__content_url__uid%2Citems%2Citems__content_url__slug%2Citems__content_type%2Citems__display_type%2Citems__content_url%2Citems__content_url__set_type_slug%2Citems__content_url__items%2Citems__content_url__items__display_type%2Citems__content_url__items__slug%2C%20items__content_url__items__title%2Citems__content_url__items__content_type%2Citems__content_url__items__content_url%2Citems__content_url__items__content_url__uid%2Citems__content_url__items__content_url__self%2Cslug%2Citems__content_url__title%2Citems__content_url__self%2Citems__position%2Citems__content_url__items__position&limit=1&items__limit=1"
}

struct HeroData{
    var this: String  = ""
    var slug: String  = ""
    var title: String = ""
    var items: [String] = []
    var synopsis: String = ""
    var imageUrl: String = ""
}

var heroData = HeroData()
