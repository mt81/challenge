//
//  CalculationEngineTests.swift
//  CalculationEngineTests
//
//  Created by matteo ugolini on 2022-03-20.
//  Copyright © 2022 TouchBistro. All rights reserved.
//

import Quick
import Nimble
@testable import CalculationEngine

extension Discount {
    static let fivePercent = Discount(id: "fivePercent", type: .percentage, value: 0.05)
    static let tenPercent = Discount(id: "tenPercent", type: .percentage, value: 0.1)
    static let twentyPercent = Discount(id: "twentyPercent", type: .percentage, value: 0.2)
    static let fiveDollars = Discount(id: "tenPercent", type: .amount, value: 5)
    static let tenDollars = Discount(id: "tenPercent", type: .amount, value: 10)
}

class CalculationEngineSpec: QuickSpec {
    override func spec() {
        describe("doscount engine") {
            it("can calculate single percentage discount") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(arrayLiteral: .fivePercent))
                expect(totalDiscount).to(equal(0.5))
            }

            it("can calculate single amunt discount") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(arrayLiteral: .fiveDollars))
                expect(totalDiscount).to(equal(5))
            }

            it("can calculate sum two percentage discounts") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(
                    arrayLiteral: .fivePercent, .tenPercent
                ))
                expect(totalDiscount).to(equal(1.45))
            }

            it("can calculate sum three discounts") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(
                    arrayLiteral: .fivePercent, .tenPercent, .twentyPercent
                ))

                // (10 * 0.05) = 0.5
                // (10 - 0.5) * 0.1 = 0.95
                // (10 - 0.5 - 0.95) * 0.2 = 1.71
                // 0.5 + 0.95 + 1.71
                expect(totalDiscount).to(equal(3.16))
            }

            it("can calculate multiple discounts with different orders") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(
                    arrayLiteral: .twentyPercent, .tenPercent, .fivePercent
                ))

                // (10 * 0.2) = 2
                // (10 - 2) * 0.1 = 0.8
                // (10 - 2 - 0.8) * 0.2 = 0.36
                expect(totalDiscount).to(equal(3.16))
            }

            it("can calculate amount and percentage discounts together") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(
                    arrayLiteral: .fiveDollars, .fivePercent
                ))
                expect(totalDiscount).to(equal(5.25))
            }

            it("can calculate amount and percentage discounts together inverted order") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(
                    arrayLiteral: .fivePercent, .fiveDollars
                ))
                expect(totalDiscount).to(equal(5.5))
            }

            it("can't return a value greater than total") {
                let totalDiscount = calculateDiscount(total: Decimal(10), discounts: ArraySlice<Discount>(
                    arrayLiteral: .tenPercent, .tenDollars
                ))
                expect(totalDiscount).to(equal(10))
            }
        }
    }
}



