//
//  Randomizer.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 6/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxDataSources

// https://en.wikipedia.org/wiki/Random_number_generation
struct PseudoRandomGenerator {
    var m_w: UInt32    /* must not be zero, nor 0x464fffff */
    var m_z: UInt32    /* must not be zero, nor 0x9068ffff */

    init(_ m_w: UInt32, _ m_z: UInt32) {
        self.m_w = m_w
        self.m_z = m_z
    }

    func get_random() -> (PseudoRandomGenerator, Int) {
        let m_z = 36969 &* (self.m_z & 65535) &+ (self.m_z >> 16);
        let m_w = 18000 &* (self.m_w & 65535) &+ (self.m_w >> 16);
        let val = ((m_z << 16) &+ m_w)
        return (PseudoRandomGenerator(m_w, m_z), Int(val % (1 << 30)))  /* 32-bit result */
    }
}

typealias NumberSection = HashableSectionModel<String, Int>

let insertItems = true
let deleteItems = true
let moveItems = true
let reloadItems = true

let deleteSections = true
let insertSections = true
let explicitlyMoveSections = true
let reloadSections = true

struct Randomizer {
    let sections: [NumberSection]

    let rng: PseudoRandomGenerator

    let unusedItems: [Int]
    let unusedSections: [String]

    init(rng: PseudoRandomGenerator, sections: [NumberSection], unusedItems: [Int] = [], unusedSections: [String] = []) {
        self.rng = rng
        self.sections = sections

        self.unusedSections = unusedSections
        self.unusedItems = unusedItems
    }

    func countTotalItemsInSections(sections: [NumberSection]) -> Int {
        return sections.reduce(0) { p, s in
            return p + s.items.count
        }
    }

    func randomize() -> Randomizer {

        var nextUnusedSections = [String]()
        var nextUnusedItems = [Int]()

        var sections = self.sections

        let sectionCount = sections.count
        let itemCount = countTotalItemsInSections(sections)

        let startItemCount = itemCount + unusedItems.count
        let startSectionCount = self.sections.count + unusedSections.count

        var (nextRng, randomValue) = rng.get_random()

        // insert sections
        for section in self.unusedSections {
            (nextRng, randomValue) = nextRng.get_random()
            let index = randomValue % (sections.count + 1)
            if insertSections {
                sections.insert(NumberSection(model: section, items: []), atIndex: index)
            }
            else {
                nextUnusedSections.append(section)
            }
        }

        // insert/reload items
        for unusedValue in self.unusedItems {
            (nextRng, randomValue) = nextRng.get_random()

            let sectionIndex = randomValue % sections.count
            let section = sections[sectionIndex]
            let itemCount = section.items.count

            // insert
            (nextRng, randomValue) = nextRng.get_random()
            if randomValue % 2 == 0 {
                (nextRng, randomValue) = nextRng.get_random()
                let itemIndex = randomValue % (itemCount + 1)

                if insertItems {
                    sections[sectionIndex].items.insert(unusedValue, atIndex: itemIndex)
                }
                else {
                    nextUnusedItems.append(unusedValue)
                }
            }
                // update
            else {
                if itemCount == 0 {
                    sections[sectionIndex].items.insert(unusedValue, atIndex: 0)
                    continue
                }

                (nextRng, randomValue) = nextRng.get_random()
                let itemIndex = itemCount
                if reloadItems {
                    nextUnusedItems.append(sections[sectionIndex].items.removeAtIndex(itemIndex % itemCount))
                    sections[sectionIndex].items.insert(unusedValue, atIndex: itemIndex % itemCount)

                }
                else {
                    nextUnusedItems.append(unusedValue)
                }
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)

        let itemActionCount = itemCount / 7
        let sectionActionCount = sectionCount / 3

        // move items
        for _ in 0 ..< itemActionCount {
            if sections.count == 0 {
                continue
            }

            (nextRng, randomValue) = nextRng.get_random()
            let sourceSectionIndex = randomValue % sections.count

            (nextRng, randomValue) = nextRng.get_random()
            let destinationSectionIndex = randomValue % sections.count

            let sectionItemCount = sections[sourceSectionIndex].items.count

            if sectionItemCount == 0 {
                continue
            }

            (nextRng, randomValue) = nextRng.get_random()
            let sourceItemIndex = randomValue % sectionItemCount

            (nextRng, randomValue) = nextRng.get_random()

            if moveItems {
                let item = sections[sourceSectionIndex].items.removeAtIndex(sourceItemIndex)
                let targetItemIndex = randomValue % (sections[destinationSectionIndex].items.count + 1)
                sections[destinationSectionIndex].items.insert(item, atIndex: targetItemIndex)
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)

        // delete items
        for _ in 0 ..< itemActionCount {
            if sections.count == 0 {
                continue
            }

            (nextRng, randomValue) = nextRng.get_random()
            let sourceSectionIndex = randomValue % sections.count

            let sectionItemCount = sections[sourceSectionIndex].items.count

            if sectionItemCount == 0 {
                continue
            }

            (nextRng, randomValue) = nextRng.get_random()
            let sourceItemIndex = randomValue % sectionItemCount

            if deleteItems {
                nextUnusedItems.append(sections[sourceSectionIndex].items.removeAtIndex(sourceItemIndex))
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)

        // move sections
        for _ in 0 ..< sectionActionCount {
            if sections.count == 0 {
                continue
            }

            (nextRng, randomValue) = nextRng.get_random()
            let sectionIndex = randomValue % sections.count
            (nextRng, randomValue) = nextRng.get_random()
            let targetIndex = randomValue % sections.count

            if explicitlyMoveSections {
                let section = sections.removeAtIndex(sectionIndex)
                sections.insert(section, atIndex: targetIndex)
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)

        // delete sections
        for _ in 0 ..< sectionActionCount {
            if sections.count == 0 {
                continue
            }

            (nextRng, randomValue) = nextRng.get_random()
            let sectionIndex = randomValue % sections.count

            if deleteSections {
                let section = sections.removeAtIndex(sectionIndex)

                for item in section.items {
                    nextUnusedItems.append(item)
                }

                nextUnusedSections.append(section.model)
            }
        }

        assert(countTotalItemsInSections(sections) + nextUnusedItems.count == startItemCount)
        assert(sections.count + nextUnusedSections.count == startSectionCount)

        return Randomizer(rng: nextRng, sections: sections, unusedItems: nextUnusedItems, unusedSections: nextUnusedSections)
    }
}
