//
//  main.swift
//  Flood
//
//  Created by Jason Oswald on 10/30/24.
//  Adapted from Alex Liu's Code from here:
//  https://github.com/alex-liu30/terrainproject
//  and this Stack Overflow thread:
//

import Foundation
import Cocoa
import UniformTypeIdentifiers
//
//print("""
//Hello User! Welcome to Alex's Bay Area Flood Simulator! Unfortunately, due to rising water levels, the Bay Area has been flooded, and so disaster management experts and computational geographers have been looking for a way to model these changes so as to come up with a solution. Thus this code focuses on simulating the Bay Area flooding problem; hopefully the guys can use this code to get closer to finding a solution!
//----------------------------------------
//""")

struct PixelData {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
}

struct Point: Hashable {
    let x: Int
    let y: Int
}

struct TerrainData {
    let rows: Int
    let columns: Int
    let waterSources: [Point]
    var elevations: [[Int]]
}

func createSampleTerrain() -> TerrainData {
    let rows = 10
    let columns = 10
    let waterSources = [Point(x: 0, y: 9)]

    let elevations: [[Int]] = [
        [5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
        [5, 4, 4, 4, 4, 4, 4, 4, 4, 5],
        [5, 4, 3, 3, 3, 3, 3, 3, 4, 5],
        [5, 4, 3, 2, 2, 2, 2, 3, 4, 5],
        [5, 4, 3, 2, 1, 1, 2, 3, 4, 5],
        [5, 4, 3, 2, 1, 1, 2, 3, 4, 5],
        [5, 4, 3, 2, 2, 2, 2, 3, 4, 5],
        [5, 4, 3, 3, 3, 3, 3, 3, 4, 5],
        [5, 4, 4, 4, 4, 4, 4, 4, 4, 5],
        [5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
    ]

    return TerrainData(rows: rows, columns: columns, waterSources: waterSources, elevations: elevations)
}

func simulateFlooding(terrain: inout TerrainData, waterLevel: Int) {
    var floodedAreas = Set<Point>()

    // Start with water sources
    for source in terrain.waterSources {
        floodedAreas.insert(source)
    }

    // Flood neighboring areas
    var changed = true
    while changed {
        changed = false
        let currentFloodedAreas = floodedAreas

        for point in currentFloodedAreas {
            let neighbors = [
                Point(x: point.x - 1, y: point.y), Point(x: point.x + 1, y: point.y),
                Point(x: point.x, y: point.y - 1), Point(x: point.x, y: point.y + 1)
            ]

            for neighbor in neighbors {
                if neighbor.y >= 0 && neighbor.y < terrain.rows && neighbor.x >= 0 && neighbor.x < terrain.columns {
                    if terrain.elevations[neighbor.y][neighbor.x] <= waterLevel && !floodedAreas.contains(neighbor) {
                        floodedAreas.insert(neighbor)
                        changed = true
                    }
                }
            }
        }
    }

    // Update terrain with flooded areas
    for point in floodedAreas {
        terrain.elevations[point.y][point.x] = min(terrain.elevations[point.y][point.x], waterLevel)
    }
}

func printTerrain(_ terrain: TerrainData, waterLevel: Int) {
    for row in 0..<terrain.rows {
        for col in 0..<terrain.columns {
            if terrain.elevations[row][col] <= waterLevel {
                print("~", terminator: "")
            } else {
                print(terrain.elevations[row][col], terminator: "")
            }
        }
        print()
    }
    print()
}

// Main simulation

let floodColor = PixelData(a:255,r:0,g:49,b:83)

let colorList:[PixelData] = [
  PixelData(r: 0, g: 102, b: 0),
  PixelData(r: 154, g: 205, b: 50),
  PixelData(r: 251, g: 236, b: 93),
  PixelData(r: 212, g: 175, b: 55),
  PixelData(r: 166, g: 60, b: 20),
]

var terrain = createSampleTerrain()

var pixelData = [PixelData](repeating: PixelData(r:0,g:0,b:0), count: Int(terrain.rows * terrain.columns))

for row in 0..<terrain.rows {
    for col in 0..<terrain.columns {
        pixelData[row * terrain.rows + col] = colorList[terrain.elevations[row][col]-1]
    }
}
let image: CGImage = pixeldata_to_image(pixels: pixelData, width: terrain.rows, height: terrain.columns)
let url = URL.documentsDirectory.appending(path: "pixeldata.png")
do {
    try image.png!.write(to: url)
    print("written")
} catch {
    print("failed write")
}


//print("Initial terrain:")
//printTerrain(terrain, waterLevel: -1)
//
//for waterLevel in 0...5 {
//    simulateFlooding(terrain: &terrain, waterLevel: waterLevel)
//    print("Water level: \(waterLevel)")
//    printTerrain(terrain, waterLevel: waterLevel)
//}
//print("Here's my explanation of the tilde symbol which I thought was cool to mention: The tilde (~) symbol in swift represents water or flooded areas in the simulation. In \"five four three tilde tilde tilde tilde three's\" example, it shows a partially flooded area.\nThe numbers (integers) represent a cell's elevations above water level, so five would mean that cell has an elevation of five.\nThe tildes at the middle of the numbers indicate that those specific areas are underwater.\nThat specific tilde function shows that the four cells represnted by tildes are flooded, or underwater.\nSo, keeping this in mind, as the water level rises, lower numbers will be replaced by tildes which ultimately represents the spread of flooding.")
