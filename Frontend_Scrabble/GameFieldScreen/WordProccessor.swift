struct WordProcessor {
    static func formWord(from grid: [[String]], start: (Int, Int), end: (Int, Int), rowCount: Int, colCount: Int) -> String {
        var startX = start.0
        var startY = start.1
        var endX = end.0
        var endY = end.1

        if startX == endX {

            while startY > 0 && !grid[startX][startY - 1].isEmpty {
                startY -= 1
            }

            while endY < colCount - 1 && !grid[endX][endY + 1].isEmpty {
                endY += 1
            }
        } else if startY == endY {

            while startX > 0 && !grid[startX - 1][startY].isEmpty {
                startX -= 1
            }

            while endX < rowCount - 1 && !grid[endX + 1][endY].isEmpty {
                endX += 1
            }
        }

        var word = ""
        if startX == endX {
            for y in startY...endY {
                word += grid[startX][y]
            }
        } else if startY == endY {
            for x in startX...endX {
                word += grid[x][startY]
            }
        }

        return word
    }
}
