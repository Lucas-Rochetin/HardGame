require './MyDataBase.rb'
require './Games.rb'

class Users
    
    def initialize()
        @sql_query = MyDatabase.new
        
        @sql_query.execute_statement("CREATE TABLE IF NOT EXISTS users (
        ID SERIAL PRIMARY KEY,
        firstname VARCHAR(255),
        lastname VARCHAR(255),
        email VARCHAR(255),
        password VARCHAR(255),
        token VARCHAR(255),
        login VARCHAR(255),
        balance DECIMAL,
        role VARCHAR(255)
        );")  

        @sql_query.execute_statement("CREATE TABLE IF NOT EXISTS usergamebought (
            userid INT,
            CONSTRAINT fk_user 
            FOREIGN KEY(userid) 
            REFERENCES users(ID),
            gameid INT,
            CONSTRAINT fk_game
            FOREIGN KEY(gameid) 
            REFERENCES games(ID)
        );")
    end


    def get_value_users_by_name(firstname, lastname)
        puts "SELECT * FROM users WHERE firstname = '#{firstname}' AND lastname = '#{lastname}';"
        return @sql_query.execute_statement("SELECT * FROM users WHERE firstname = '#{firstname}' AND lastname = '#{lastname}';").collect{ |row| row }
    end

    def get_value_users_by_login(login)
        puts "SELECT * FROM users WHERE login = '#{login}';"
        return @sql_query.execute_statement("SELECT * FROM users WHERE login = '#{login}';").collect{ |row| row }[0]
    end
    def get_value_usergamebought_by_id(userid, gameid)
        puts "SELECT * FROM usergamebought WHERE userid = '#{userid}' AND gameid = '#{gameid}';"
        return @sql_query.execute_statement("SELECT * FROM usergamebought WHERE userid = '#{userid}' AND gameid = '#{gameid}';").collect{ |row| row }
    end
    
    def get_games_bought_by_user(login)
        user = self.get_value_users_by_login(login)
        user_already_exist = self.user_exist(login)
        if user_already_exist != -1
            userid = user["id"].to_i
            puts "SELECT games.name, games.genre, games.platform FROM games INNER JOIN usergamebought ON games.id = usergamebought.gameid WHERE usergamebought.userid = #{userid};"
            return @sql_query.execute_statement("SELECT games.name, games.genre, games.platform FROM games INNER JOIN usergamebought ON games.id = usergamebought.gameid WHERE usergamebought.userid = #{userid};").collect{ |row| row }
        else 
            return -1
        end
    end

    def get_all_users()
        @sql_query.execute_statement("SELECT * FROM users;").collect{ |row| row }
    end

    def users_add_money(login, money)
        user = self.get_value_users_by_login(login)
         if user.any?
            current_balance = user['balance'].to_i
            new_balance = current_balance + money.to_i
            @sql_query.execute_statement("UPDATE users SET balance = #{new_balance} WHERE login = '#{login}';")
            
            puts "Money added successfully"
            return 1
        else
            puts "User not found"
            return -1
        end
    end

    def user_exist(login)
        if self.get_value_users_by_login(login) != nil
            return 1
        else 
            return -1
        end
    end

    def user_already_created(firstname, lastname)
        if self.get_value_users_by_name(firstname, lastname).empty?
            return 1
        else 
            return -1
        end
    end

    def user_already_bought_game(login, game_name, game_controller)
        user = self.get_value_users_by_login(login)
        game = game_controller.get_value_games_by_name(game_name)
        user_already_exist = self.user_exist(login)
        if user_already_exist != -1
            userid = user["id"].to_i
            gameid = game["id"].to_i
            if self.get_value_usergamebought_by_id(userid, gameid).empty?
                return 1
            else 
                return -1
            end
        else 
            return -1
        end
    end

    def users_fund_game_cost(login, game_name, game_controller)
        user = self.get_value_users_by_login(login)
        game = game_controller.get_value_games_by_name(game_name)
        user_already_exist = self.user_exist(login)
        if user_already_exist != -1
            user_fund = user["balance"].to_i
            game_cost = game["cost"].to_i
            compare_money = user_fund - game_cost
            if compare_money >= 0
                return 1
            else
                return -1
            end
        else 
            return -1
        end
    end

    def users_buy_game(login, game_name, game_controller)
        user = self.get_value_users_by_login(login)
        game = game_controller.get_value_games_by_name(game_name)
        userid = user["id"].to_i
        gameid = game["id"].to_i
        user_already_exist = self.user_exist(login)
        if user_already_exist != -1
            user_fund = user["balance"].to_i
            if game.any?
                game_cost = game["cost"].to_i
                new_fund = user_fund - game_cost
                @sql_query.execute_statement("UPDATE users SET balance = #{new_fund} WHERE login = '#{login}';")
                insert_gamebought = @sql_query.execute_statement("INSERT INTO usergamebought (userid, gameid) VALUES (#{userid}, #{gameid});")
                return 1
            else 
                return -1
            end
        else 
            return -1
        end
    end
    
    def insert_users_by_name (firstname, lastname, login, email, password)
        if self.get_value_users_by_name(firstname, lastname).empty?
            @sql_query.execute_statement("INSERT INTO users (firstname, lastname, login, email, password, balance) VALUES
            ('#{firstname}',
            '#{lastname}',
            '#{login}',
            '#{email}',
            '#{djb2_hash(password)}',
            '0');")
            puts "User added successfuly"
            return self.get_value_users_by_name(firstname, lastname)            
        else
            puts "Failed to create User"
            return -1
        end
    end

    def insert_token_by_login (login)
        token = djb2_hash(login + "_token")
        if self.get_value_users_by_login(login) != nil
            @sql_query.execute_statement("UPDATE users SET token = '#{token}'
            WHERE login = '#{login}';")
            puts "Token added successfuly"
            return 1           
        else
            puts "failed to create Token"
            return -1
        end
    end

    def update_users_by_login(login, firstname, lastname, email, password)
        if self.get_value_users_by_login(login) != nil
            puts "UPDATE users SET firstname = '#{firstname}', lastname = '#{lastname}', email = '#{email}', password = '#{password}'
            WHERE login = '#{login}';";
            @sql_query.execute_statement("UPDATE users SET firstname = '#{firstname}', lastname = '#{lastname}', email = '#{email}', password = '#{password}'
            WHERE login = '#{login}';")
            puts "User updated successfuly"
            return 1
        else
            puts "There is no User with this login: #{login}"
            return -1
        end
    end

    def delete_by_users_by_login (login)
        if self.get_value_users_by_login(login) != nil
            @sql_query.execute_statement("DELETE FROM users WHERE login = '#{login}';")
            puts "User deleted successfuly"
            return 1
        else
            puts "failed to delete #{login} because it doesn't exist"
            return -1
        end
    end

    def djb2_hash(string)
        hash = 5381
        string.each_byte { |c| hash = ((hash << 5) + hash) + c }
        hash
    end

    def login_users(login, password)
        user = get_value_users_by_login(login)
        user_created = user_exist(login)
        if user_created == 1
            user = {token: "user_token", password: djb2_hash("#{password}")}
            hashed_password = djb2_hash(password)
        
            if hashed_password == user[:password]
                {
                    connection: true,
                    token: user[:token]
                }.to_json
                else
                {
                    connection: false
                }.to_json
            end
        else 
            return -1
            puts "User doesn't exist. Create an account to connect"
        end
    end 

    def verif_token(login, token)
        user = get_value_users_by_login(login)
        user_token = user.first["token"]
        actual_token = token
        if user_token == actual_token
            return 1
            puts "Tokens are similar user is still connected"
        else 
            return -1
            puts "Tokens are different user may be disconnected"
        end
    end
end