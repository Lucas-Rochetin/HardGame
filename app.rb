require 'sinatra/base'
require 'json'
require 'pg'
require './Users.rb'
require './Games.rb'
require './Rgpd.rb'

$stdout.sync = true

def format_login (fn, ln)
    "#{fn.downcase}_#{ln.downcase}"
end
 
class IntranetAPI < Sinatra::Base
    set :bind, '0.0.0.0'
    set :port, 5763
    
    get '/' do
        content_type :json
        {
            "api_status": true,
            "api_author": "Lucas Rochetin"
        }.to_json
    end

    get '/users' do 
        content_type :json

        user_controller = Users.new
        hardgame_users = user_controller.get_all_users()
        hardgame_users.to_json
        
    end

    get '/users/:login' do 
        content_type :json

        user_controller = Users.new

        required_keys = ["login"]
        missing_keys = required_keys.select { |key| !params.key?(key) }

        if missing_keys.empty?
            user_exist = user_controller.user_exist(params["login"])
            if user_exist != -1
                users_login = user_controller.get_value_users_by_login(params["login"])
                if users_login != -1
                    purchased_games = user_controller.get_games_bought_by_user(params["login"])
                    user_with_games = users_login.merge({ "purchased_games" => purchased_games })
                    status 200 
                    user_with_games.to_json  
                else
                    status 404
                    {
                        status: 'error',
                        error: "User not found",
                        login: params.key?("login")
                    }.to_json
                end
            else 
                status 404
                    {
                        status: 'error',
                        error: "User not found",
                        login: params.key?("login")
                    }.to_json
            end
        end
    end

    post '/users' do
        content_type :json
        user_controller = Users.new
        request_body = JSON.parse(request.body.read)
        required_keys = ["firstname", "lastname", "email", "password", "password_repeat"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }
        if missing_keys.empty?
            request_body["login"] = format_login(request_body["firstname"], request_body["lastname"])
            users_created = user_controller.user_already_created(request_body["firstname"], request_body["lastname"])
            if users_created != -1
                if request_body["password"] == request_body["password_repeat"]
                    users_insert = user_controller.insert_users_by_name(request_body["firstname"], request_body["lastname"], request_body["login"], request_body["email"], request_body["password"])
                    if users_insert != -1
                        status 201 
                        {
                            status: 'success',
                            message: "User added successfully",
                            users_insert: users_insert
                        }.to_json
                    else
                        status 404
                        {
                            status: 'error',
                            error: "Invalid input: email is missing",
                            firstname: request_body.key?("firstname"),
                            lastname: request_body.key?("lastname"),
                            login: request_body.key?("login"),
                            email: request_body.key?("email"),
                            password: request_body.key?("password"),
                            password_repeat: request_body.key?("password_repeat")
                        }.to_json
                    end
                else 
                    status 404
                    {
                        status: 'error',
                        error: "Please enter the same password",
                        password: request_body.key?("password"),
                        password_repeat: request_body.key?("password_repeat")
                    }.to_json
                end
            else
                status 404
                    {
                        status: 'error',
                        error: "User already exist",
                        login: request_body["login"]
                    }.to_json
            end
        else 
            status 404
                {
                    status: 'error',
                    error: "Invalid input: one or more input is missing",
                    firstname: request_body.key?("firstname"),
                    lastname: request_body.key?("lastname"),
                    login: request_body.key?("login"),
                    email: request_body.key?("email"),
                    password: request_body.key?("password")
                }.to_json
        end
    end

    put '/users/:login' do
        content_type :json
        user_update_controller = Users.new
        if params.key?("login") && params.key?("firstname") && params.key?("lastname") && params.key?("email") && params.key?("password") && params.key?("password_repeat")
            user_update = user_update_controller.update_users_by_login(params["login"], params["firstname"], params["lastname"], params["email"], params["password"])
            if user_update != -1
                status 200
                {
                    status: 'success',
                    message: "User updated successfully",
                    user_update: user_update
                }.to_json
            else
                status 404
                {
                    status: 'error',
                    error: "User not found for #{login}",
                    login: params.key?("login"),
                    firstname: params.key?("firstname"),
                    lastname: params.key?("lastname"),
                    email: params.key?("email"),
                    password: params.key?("password")
                }.to_json
            end
        end
    end

    post '/users/:login/add_money' do
        content_type :json
        user_login_controller = Users.new
        request_body = JSON.parse(request.body.read)

        required_keys = ["money"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty? && params.key?("login")
            user_login = user_login_controller.users_add_money(params["login"], request_body["money"])
            if user_login != -1
                status 200
                {
                    status: 'success',
                    message: "Money added successfully",
                    user_login: user_login
                }.to_json
            else
                status 404
                {
                    status: 'error',
                    error: "User not found",
                    login: request_body.key?("login")
                }.to_json
            end
        end
    end

    post '/users/:login/buy/:game_name' do
        content_type :json
        user_buy_controller = Users.new
        game_buy_controller = Games.new
        if params.key?("login") && params.key?("game_name")
            user_exist = user_buy_controller.user_exist(params["login"])
            if user_exist != -1
                user_fund = user_buy_controller.users_fund_game_cost(params["login"], params["game_name"], game_buy_controller)
                if user_fund != -1
                    user_already_bought = user_buy_controller.user_already_bought_game(params["login"], params["game_name"], game_buy_controller)
                    if user_already_bought != -1
                        user_buy = user_buy_controller.users_buy_game(params["login"], params["game_name"], game_buy_controller)
                        if user_buy != -1
                            status 200
                            {
                                status: 'success',
                                message: "Game purchased successfuly",
                                user_buy: user_buy
                            }.to_json
                        else
                            status 404
                            {
                                status: 'error',
                                error: "User or Game not found",
                                login: params.key?("login"),
                                game_name: params.key?("game_name")
                            }.to_json
                        end
                    else 
                        status 404
                        {
                            status: 'error',
                            error: "User already bought the game",
                            login: params.key?("login"),
                            game_name: params.key?("game_name")
                    }.to_json
                    end
                else
                    status 400
                    {
                        status: 'error',
                        error: "Insufficient funds"
                    }.to_json
                end
            else 
                status 404
                {
                    status: 'error',
                    error: "User is not found"
            }.to_json
            end
        end
    end

    
    delete '/users/:login' do
        content_type :json
        user_login_controller = Users.new
        request_body = JSON.parse(request.body.read)

        required_keys = ["login"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
            user_login = user_login_controller.delete_by_users_by_login(login)
            if user_login != -1
                status 200
                {
                    status: 'success',
                    message: "User updated successfully",
                    user_login: user_login
                    }.to_json
            else
                status 404
                {
                    status: 'error',
                    error: "User not found",
                    login: request_body.key?("login")
                }.to_json
            end
        end
    end

    get '/games' do 
        content_type :json

        games_controller = Games.new
        hardgame_games = games_controller.get_all_games()
        hardgame_games.to_json
    end

    get '/games/:name' do 
        content_type :json

        games_controller = Games.new
        request_body = params
        required_keys = ["name"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
            game_name = games_controller.get_value_games_by_name(request_body["name"])
            if game_name != -1
                status 200 
                game_name.to_json
            else
                status 404
                {
                status: 'error',
                error: "Game not found",
                name: request_body.key?("name")
            }.to_json
            end
        end
    end

    post '/games' do
        content_type :json
        game_controller = Games.new
        request_body = JSON.parse(request.body.read)

        required_keys = ["name", "platform", "genre", "release_year", "cost"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
            game_exist = game_controller.game_already_exist(request_body["name"])
            if game_exist != -1
                game_insert = game_controller.insert_games_by_name(request_body["name"], request_body["platform"], request_body["genre"], request_body["release_year"], request_body["cost"])
                if game_insert != -1
                    status 201 
                    {
                        status: 'success',
                        message: "Game added successfuly",
                        game_insert: game_insert
                    }.to_json
                else
                    status 404
                    {
                        status: 'error',
                        error: "Invalid input: name is missing",
                        name: request_body.key?("name"),
                        platform: request_body.key?("platform"),
                        genre: request_body.key?("genre"),
                        release_year: request_body.key?("release_year"),
                        cost: request_body.key?("cost")
                    }.to_json
                end
            else 
                status 404
                    {
                        status: 'error',
                        error: "Game already is in library",
                        name: request_body.key?("name")
                    }.to_json
            end
        end
    end

    put '/games/:name' do
        content_type :json
        game_update_controller = Games.new
        request_body = JSON.parse(request.body.read)
    
        required_keys = ["name", "platform", "genre", "release_year", "cost"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
            game_update = game_update_controller.update_games_by_name(request_body["name"], request_body["platform"], request_body["genre"], request_body["release_year"], request_body["cost"])
            if game_update != -1
                status 200
                {
                    status: 'success',
                    message: "Game updated successfuly",
                    game_update: game_update
                }.to_json
            else
                status 404
                {
                    status: 'error',
                    error: "Invalid input: name is missing",
                    name: request_body.key?("name"),
                    platform: request_body.key?("platform"),
                    genre: request_body.key?("genre"),
                    release_year: request_body.key?("release_year"),
                    cost: request_body.key?("cost")
                }.to_json
            end
        end
    end

    delete '/games/:name' do
        content_type :json
        game_name_controller = Users.new
        request_body = JSON.parse(request.body.read)

        required_keys = ["name"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
            game_name = game_name_controller.delete_by_games_by_name(name)
            if game_name != -1
                status 200
                {
                    status: 'success',
                    message: "Game deleted successfuly",
                    game_name: game_name
                }.to_json
            else
                status 404
                {
                    status: 'error',
                    error: "game not found",
                    name: request_body.key?("name")
                }.to_json
            end
        end
    end

    post '/api/rgpd/add_new_message' do
        content_type :json
        rgpd_controller = Rgpd.new
        request_body = JSON.parse(request.body.read)

        required_keys = ["message"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
            rgpd_message = rgpd_controller.insert_message(request_body["message"])
            if rgpd_message != -1
                status 201
                {
                    status: 'success',
                    message: "Message added successfuly"
                }.to_json
            else 
                status 400
                {
                    status: 'error',
                    error: "Message could not be added"
                }.to_json
            end
        else
            status 400
            {
                status: 'error',
                error: "Invalid input: message is missing"
            }.to_json
        end
    end

    post '/api/user/connect' do
        content_type :json
        user_connect_controller = Users.new
        request_body = JSON.parse(request.body.read)

        required_keys = ["login", "password"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
            user_connect = user_connect_controller.login_users(request_body["login"], request_body["password"])
            if user_connect != -1
                created_token = user_connect_controller.insert_token_by_login(request_body["login"])
                if created_token != -1
                    status 201
                    {
                        status: 'success',
                        message: "Token created successfully"
                    }.to_json
                else
                    status 404
                    {
                        status: 'error',
                        error: "Token could not be created"
                    }.to_json
                end
                status 201
                {
                    status: 'success',
                    message: "User connected successfully"
                }.to_json
            else
                status 404
                {
                    status: 'error',
                    error: "Invalid login or password"
                }.to_json
            end
        else
            status 404
            {
                status: 'error',
                error: "Invalid input: login or password missing !"
            }.to_json
        end
    end

    post '/api/user/verif_token' do
        content_type :json
        request_body = JSON.parse(request.body.read)
        user_token_controller = Users.new

        required_keys = ["login"]
        missing_keys = required_keys.select { |key| !request_body.key?(key) }

        if missing_keys.empty?
        token_actual = request_body['user_token']
            verif_token_user = user_token_controller.verif_token(request_body["login"], token_actual)
            if verif_token_user != -1
                status 200
                {
                    status: 'valid',
                    message: "Valid token user still connected"
                }.to_json
            else 
                status 404
                {
                    status: 'error',
                    error: "Invalid or expired token"
                }.to_json
            end
        else
            status 404
            {
                status: 'error',
                error: "Invalid login and/or expired token"
            }.to_json
        end
    end
end


IntranetAPI.run! if __FILE__ == $0