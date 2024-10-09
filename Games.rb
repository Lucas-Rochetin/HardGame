require './MyDataBase.rb'

class Games
    
    def initialize()
        @sql_query = MyDatabase.new
        
        @sql_query.execute_statement("CREATE TABLE IF NOT EXISTS games (
        ID SERIAL PRIMARY KEY,
        name VARCHAR(255),
        platform VARCHAR(255),
        genre VARCHAR(255),
        release_year DATE,
        cost DECIMAL(10, 2)
        );")  
    end

    def get_value_games_by_name(name)
        puts "SELECT * FROM games WHERE name = '#{name}';"
        return @sql_query.execute_statement("SELECT * FROM games WHERE name = '#{name}';").collect{ |row| row }[0]
    end

    def test_game_exist_by_name(name)
       return @sql_query.execute_statement("SELECT * FROM games WHERE name = '#{name}';").collect{ |row| row }.count == 0
    end
    
    def get_all_games()
        @sql_query.execute_statement("SELECT * FROM games;").collect{ |row| row }
    end
    
    def game_already_exist(name)
        if self.test_game_exist_by_name(name)
            return 1
        else 
            return -1
        end
    end

    def insert_games_by_name (name, platform, genre, release_year, cost)
        if self.test_game_exist_by_name(name)
            @sql_query.execute_statement("INSERT INTO games (name, platform, genre, release_year, cost) VALUES
            ('#{name}',
            '#{platform}',
            '#{genre}',
            '#{release_year}',
            '#{cost}');")
            puts "Game added successfuly"
            return self.get_value_games_by_name(name)            
        else
            puts "failed to create Game"
            return -1
        end
    end

    def update_games_by_name(name, platform, genre, release_year, cost)
        if self.test_game_exist_by_name(name) != 0
            puts "UPDATE games SET name = '#{name}', platform = '#{platform}', genre = '#{genre}', release_year = '#{release_year}', cost = '#{cost}'
            WHERE name = '#{name}';";
            @sql_query.execute_statement("UPDATE games SET name = '#{name}', platform = '#{platform}', genre = '#{genre}', release_year = '#{release_year}', cost = '#{cost}'
            WHERE name = '#{name}';")
            puts "Game updated successfuly"
            return 1
        else
            puts "Invalid input: name is missing"
            return -1
        end
    end
    
    def delete_by_games_by_name (name)
        if self.test_game_exist_by_name(name) != 0
            @sql_query.execute_statement("DELETE FROM games WHERE name = '#{name}';")
            puts "Game deleted successfuly"
            return 1
        else
            puts "failed to delete Game #{name} because it doesn't exist"
            return -1
        end
    end
end