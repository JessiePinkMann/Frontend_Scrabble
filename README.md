# Frontend_Scrabble
Making da front for scrabble game!!

# Scrabble iOS App

## Описание проекта
Проект представляет собой приложение для игры в Scrabble на iOS, разработанное с использованием Swift. Цель проекта - создание приложения, в котором игроки могут соревноваться, размещая слова на игровом поле и зарабатывая очки.

## Технологии
- Swift
- UIKit или SwiftUI

## Что делаем
- Подключение к backend-сервису: [Server_Scrabble](https://github.com/prettycrewcutyulia/Server_Scrabble/)
- Пошаговая игра: игроки поочередно размещают слова на доске
- Подсчет очков с учетом стоимости букв и бонусов

## Экраны [WIP]

### Authorization (1 point)

* **DONE** App allows you to register an account (0.4 points)
* *App allows you to delete account (0.1 points) (TODO: add to API)*
* **DONE** App allows you to authorize with an existing account (0.4 points)
* **DONE** App allows you to log out of the account (0.1 points)

### Rooms (3.3 points)
* **DONE** App allows to create a gaming room, which grants admin rights for this room to the creator (0.3 points)
* App allows admin to delete room (0.3 points)
* Other players can join the gaming room (0.3 points)
* **DONE** Other players can leave the gaming room (0.2 points)
* **DONE** **Players can join private rooms using invite code (1.5 points)**
* Players can be removed by the room admin (0.4 points)
* Admin status can be transferred to another player (0.3 points)

### Game (4.4 points)

* Admin can start a game (from room) (0.2 points)
* Admin can pause and then continue the game (0.2 points)
* **Players can put words in clockwise order (1.0 points)**
* **DONE** Words placed are validated (0.5 points)
* **There is scoreboard that is shown to every player that indicates who is closer to victory (1.5 points)**
* **After game finishes the winner is shown to everyone (1.0 points)**

### Other

* **Probably yes** The code is written in MVVM or Clean Swift or TCA 1.2 points
* Dependency injection with unit/integration tests (two or more) (1.0 points)
* Good code style (0.5 points)
* **Game can be played again with the same players (1.5 points)**
* **Empty rooms are deleted (0.5 points)**
* Letter tiles left counter is present (0.3 points)
* Exchange letters in hand with the bag (skips their turn) (0.3 points)
* **Bonus: Players can get hints for words to place (1.5 points)**
* **Probably yes** Bonus: Any improvement you do to server to make tasks for this group work possible grant you 0.5 points up to 2 points


## Фиксы в реализации сервера

1. Комнату можно удалить только если в ней есть игроки, иначе выдает ошибку "Комнаты не существует" (вводит в заблуждение) - закомментили эту проверку
```swift
func deleteRoom(_ req: Request) async throws -> HTTPStatus {
    if let roomIdString = req.parameters.get("roomId"), let roomId = UUID(roomIdString) {
        let rooms = try await GamerIntoRoom.query(on: req.db)
            .filter(\.$roomId == roomId).all()
        // if !rooms.isEmpty {
            let room = try await GameRoom.query(on: req.db)
                .filter(\.$id == roomId).first()
            try await rooms.delete(on: req.db)
            try await room?.delete(on: req.db)
        // } else {
        //     throw Abort(.custom(code: 404, reasonPhrase: "Данной комнаты не существует"))
        // }
        return .noContent
    } else {
        throw Abort(.notFound)
    }
}
```

2. ID игрока выплевывается только на регистрации. Потом никак невозможно его получить - а нужен он много где. Хотелось бы хотя бы на логине получать его помимо JWT токена. Либо можно добавить в API возможность получения айди по нику. Фикс - добавили LoginResponse и поменяли login handler:
```swift
struct UserLoginResponse: Content {
    let id: String
    let JWT: String
    
    init(id: String, JWT: String) {
        self.id = id
        self.JWT = JWT
    }
}

func login(_ req: Request) async throws -> UserLoginResponse {
    // Предположим, что у нас есть функция для проверки учетных данных пользователя
    let credentials = try req.content.decode(UserCredentials.self)
    let user = try await authenticate(credentials: credentials, on: req)
    
    let token = try TokensHelper.createAccessToken(from: user, signers: req.application.jwt.signers)
    
    return UserLoginResponse(id: user.id?.uuidString ?? "", JWT: token)
}
```

3. Добавлены getAllUsers, getUserByNickname и getUserById чтобы облегчить жизнь (например чтобы можно было людям в комнате их ники выводить, админа комнаты определять)
```swift
func getUserById(_ req: Request) async throws -> User {
    if let userIdString = req.parameters.get("id"), let userId = UUID(userIdString) {
        if let user = try await User.query(on: req.db)
            .filter(\.$id == userId)
            .first() {
            let newUser = User(id: user.id, nickName: user.nickName, password: "")
            return newUser
        }
        else {
            throw Abort(.notFound)
        }
    }
    throw Abort(.badRequest, reason: "Couldn't process request")
}

func getUserByNickname(_ req: Request) async throws -> User {
    if let userName = req.parameters.get("nickname") {
        if let user = try await User.query(on: req.db)
            .filter(\.$nickName == userName)
            .first() {
            let newUser = User(id: user.id, nickName: user.nickName, password: "")
            return newUser
        }
        else {
            throw Abort(.notFound)
        }
    }
    throw Abort(.badRequest, reason: "Couldn't process request")
}

func getAllUsers(_ req: Request) async throws -> [User] {
    let users = try await User.query(on: req.db).all()
    
    return users.map {user in
        let newUser = User(id: user.id, nickName: user.nickName, password: "")
        return newUser
    }
}
```

## Crew
- Mr. 3ybactuk <3
- Sir Jessie
- Mrs Alsu
