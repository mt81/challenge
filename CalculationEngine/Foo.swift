//
//  Foo.swift
//  CalculationEngine
//
//  Created by matteo ugolini on 2022-03-20.
//  Copyright © 2022 TouchBistro. All rights reserved.
//

import Foundation
import CoreVideo

public struct Category: Hashable {
    public let id: String
}

public struct Item: Hashable {
	public let name: String
	public let category: Category
	public let price: Decimal
	public let isTaxExempt: Bool
}

public struct Discount: Hashable {
    public enum TaxType {
		case percentage
        case amount
    }

    public let id: String
    public let type: TaxType
    public let value: Decimal
}

public struct Tax: Hashable {
    public let id: String
    public let percentage: Decimal
    public let categories: [Category]?
}

public struct Bill {
    public let itemsTotal: Decimal
    public let totalTax: Decimal
    public let totalDiscount: Decimal
    public let total: Decimal
}



public func calculate(items: [Item], taxes: [Tax], discounts: [Discount]) -> Bill {
    var index: [Category: [Tax]] = [:]
    var genericTaxes: [Tax] = []

    taxes.forEach { tax in
        if let categories = tax.categories {
            categories.forEach{ category in
                var appliedTaxes = index[category] ?? []
                appliedTaxes.append(tax)
                index[category] = appliedTaxes
            }
        }

        genericTaxes.append(tax)
    }

    let itemsTotal = items.map { $0.price }.reduce(Decimal.zero, +)
    let totalTaxes = items.map { item -> Decimal in
        guard item.isTaxExempt else { return .zero }

        let appliedTaxes = genericTaxes + (index[item.category] ?? [])
    	return appliedTaxes.map { tax in
        	item.price * tax.percentage
        }.reduce(Decimal.zero, +)
    }.reduce(Decimal.zero, +)

    let partialBeforeDiscount = itemsTotal + totalTaxes
    let totalDiscount = min(partialBeforeDiscount,  calculateDiscount(total: partialBeforeDiscount, discounts: discounts.suffix(from: 0)))

    return Bill(
        itemsTotal: itemsTotal,
        totalTax: totalTaxes,
        totalDiscount: totalDiscount,
        total: partialBeforeDiscount - totalDiscount
    )
}

func calculateDiscount(total: Decimal, discounts: ArraySlice<Discount>) -> Decimal {
    guard let discount = discounts.last else { return 0 }

    let cumulativeDiscount = calculateDiscount(total: total, discounts: discounts.prefix(discounts.count - 1))
    let partialDiscount = discount.calculate(on: total - cumulativeDiscount)

    let currentDiscount = partialDiscount + cumulativeDiscount
    guard currentDiscount < total else {
        return total
    }

    return currentDiscount
}

extension Discount {
    func calculate(on amount: Decimal) -> Decimal {
        switch type {
        case .percentage: return amount * value
        case .amount: return value
        }
    }
}

public func calculateTax(items: [Item], tax: Tax) {

}
