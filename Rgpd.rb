require './MyDataBase.rb'

class Rgpd
    
    def initialize()
        @sql_query = MyDatabase.new
        
        @sql_query.execute_statement("CREATE TABLE IF NOT EXISTS rgpd (
        ID SERIAL PRIMARY KEY,
        message TEXT
        );")  
    end
    
    def get_value_rgpd_by_id(id)
        puts "SELECT * FROM rgpd WHERE ID = '#{id}';"
        return @sql_query.execute_statement("SELECT * FROM rgpd WHERE ID = '#{id}';").collect{ |row| row }
    end

    def get_value_rgpd_by_message(message)
        puts "SELECT * FROM rgpd WHERE message = '#{message}';"
        return @sql_query.execute_statement("SELECT * FROM rgpd WHERE message = '#{message}';").collect{ |row| row }
    end
    
    def get_all_rgpd()
        @sql_query.execute_statement("SELECT * FROM rgpd;").collect{ |row| row }
    end

    def insert_message(message)
        @sql_query.execute_statement("INSERT INTO rgpd (message) VALUES
            ('#{message}');")
        puts  "Message added successfuly"
    end

    def delete_by_rgpd_by_id (id)
        if self.get_value_rgpd_by_id(id).count == 1
            @sql_query.execute_statement("DELETE FROM rgpd WHERE rgpdID = '#{id}';")
            puts "deleted #{id}"
            return 1
        else
            puts "failed to delete id: #{id} because it doesn't exist"
            return 0
        end
    end
end