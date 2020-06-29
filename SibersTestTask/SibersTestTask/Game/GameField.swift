//
//  GameField.swift
//  SibersTestTask
//
//  Created by Denis Kamkin on 29.06.2020.
//  Copyright © 2020 Denis Kamkin. All rights reserved.
//

import Foundation

class GameField {
    var roomsInRow: Int
    var roomsInColumn: Int
    var playField: [[Room]]
    init(roomsInRow: Int, roomsInColumn: Int) {
        self.roomsInRow = roomsInRow
        self.roomsInColumn = roomsInColumn
        self.playField = [[Room]](repeating: [Room](repeating: Room(), count: roomsInColumn), count: roomsInRow)
        createRandomMaze()
    }
    func createRandomMaze() {
        createRandowMazeEller()
        addItemInRandomRoom(item: Chest())
        addItemInRandomRoom(item: KeyForChest())
        //createRandomMaze(withWayLength: roomsInRow*roomsInColumn)
    }
    
    func addItemInRandomRoom(item: Item) {
        let x = Int.random(in: 1...roomsInRow)
        let y = Int.random(in: 1...roomsInColumn)
        getRoom(at: (x,y))?.items.append(item)
    }
    
    func createRandowMazeEller() {
        struct EllerRoom {
            var multiplicity: Int
            var haveRightWall: Bool
            var haveDownWall: Bool
        }
        
        func findEmptyMultiplicity(rooms: [EllerRoom]) -> Int {
            for multiplicity in 1...rooms.count {
                var isFound = true
                for index in rooms.startIndex..<rooms.count {
                    if rooms[index].multiplicity == multiplicity {
                        isFound = false
                        break
                    }
                }
                if isFound {
                    return multiplicity
                }
            }
            return rooms.count+1
        }
        
        for i in playField.indices { //создаем комнаты
            for j in playField[i].indices {
                playField[i][j] = Room()
                RoomItemsFiller.fillRoom(room: playField[i][j]) //добавляем случайные предметы
            }
        }

        var currentLine = [EllerRoom]()
        for x in 1...roomsInRow {
            currentLine.append(EllerRoom(multiplicity: x, haveRightWall: false, haveDownWall: false))
        }
        currentLine[currentLine.endIndex-1].haveRightWall = true
        for line in 1...roomsInColumn+1 {
            if line != 1 {
                if line == roomsInColumn+1 {
                    for x in 1...roomsInRow {
                        currentLine[currentLine.startIndex - 1 + x].haveDownWall = true
                    }
                    for x in 1...roomsInRow-1 {
                        if currentLine[currentLine.startIndex - 1 + x].multiplicity != currentLine[currentLine.startIndex - 1 + x + 1].multiplicity {
                            currentLine[currentLine.startIndex - 1 + x].haveRightWall = false
                            currentLine[currentLine.startIndex - 1 + x + 1].multiplicity = currentLine[currentLine.startIndex - 1 + x].multiplicity
                        }
                        
                    }
                }
                
                for x in 1...roomsInRow {
                    if !currentLine[currentLine.startIndex - 1 + x].haveRightWall {
                        _ = addNewDoor(at: (x, line-1), door: .right)
                    }
                    if !currentLine[currentLine.startIndex - 1 + x].haveDownWall {
                        _ = addNewDoor(at: (x, line-1), door: .down)
                    }
                }
                if line == roomsInColumn+1 {
                    return
                }
                //remove right walls
                for x in currentLine.startIndex..<currentLine.endIndex-1 {
                    currentLine[x].haveRightWall = false
                }
                //remove down walls and change room's multiplicity
                for x in currentLine.startIndex..<currentLine.endIndex {
                    if currentLine[x].haveDownWall {
                        currentLine[x].haveDownWall = false
                        currentLine[x].multiplicity = findEmptyMultiplicity(rooms: currentLine)
                    }
                }
            }
            //add right walls
            for roomIndex in currentLine.startIndex..<currentLine.count-1 {
                if Bool.random() || (currentLine[roomIndex+1].multiplicity == currentLine[roomIndex].multiplicity) {
                    currentLine[roomIndex].haveRightWall = true
                } else {
                    currentLine[roomIndex+1].multiplicity = currentLine[roomIndex].multiplicity
                }
            }
            //add down walls
            var multiplicityHaveDownDoor = false
            for roomIndex in currentLine.startIndex..<currentLine.count {
                if roomIndex == currentLine.startIndex && currentLine[roomIndex].haveRightWall {
                    multiplicityHaveDownDoor = false
                    continue
                }
                if roomIndex != currentLine.startIndex && currentLine[roomIndex-1].haveRightWall && currentLine[roomIndex].haveRightWall {
                    multiplicityHaveDownDoor = false
                    continue
                }
                if Bool.random() && !(currentLine[roomIndex].haveRightWall && !multiplicityHaveDownDoor){
                    currentLine[roomIndex].haveDownWall = true
                } else {
                    multiplicityHaveDownDoor = true
                }
                if currentLine[roomIndex].haveRightWall {
                     multiplicityHaveDownDoor = false
                }
            }
        }
    }
    
    func getRoom(at roomPosition: RoomPosition) -> Room? {
        switch roomPosition {
        case (1...roomsInRow,1...roomsInColumn):
            return playField[playField.startIndex+roomPosition.x - 1][playField[playField.startIndex].startIndex+roomPosition.y - 1]
        default:
            return nil
        }
    }
    
    func addNewDoor(at roomPosition: RoomPosition, door: Door) -> Bool{
        guard let room = getRoom(at: roomPosition) else {
            return false
        }
        switch door {
        case .left:
            guard let adjacentRoom = getRoom(at: (roomPosition.x - 1, roomPosition.y)) else {
                return false
            }
            room.addDoor(.left)
            adjacentRoom.addDoor(.right)
            return true
        case .right:
            guard let adjacentRoom = getRoom(at: (roomPosition.x + 1, roomPosition.y)) else {
                return false
            }
            room.addDoor(.right)
            adjacentRoom.addDoor(.left)
            return true
        case .up:
            guard let adjacentRoom = getRoom(at: (roomPosition.x, roomPosition.y - 1)) else {
                return false
            }
            room.addDoor(.up)
            adjacentRoom.addDoor(.down)
            return true
        case .down:
            guard let adjacentRoom = getRoom(at: (roomPosition.x, roomPosition.y + 1)) else {
                return false
            }
            room.addDoor(.down)
            adjacentRoom.addDoor(.up)
            return true
        }
    }

    func printMaze() {
        var startWallString = String(" ")
        for _ in 1...roomsInRow {
            startWallString.append("_ ")
        }
        print(startWallString)
        for j in 1...roomsInColumn {
            var line = String("")
            for i in 1...roomsInRow {
                guard let haveDownDoor = getRoom(at: (i, j))?.haveDoor(.down) else {
                    continue
                }
                guard let haveLeftDoor = getRoom(at: (i, j))?.haveDoor(.left) else {
                    continue
                }
                line.append(!haveLeftDoor ? "|" : " ")
                line.append(!haveDownDoor ? "_" : " ")
            }
            line.append("|")
            print(line)
        }
    }
}

