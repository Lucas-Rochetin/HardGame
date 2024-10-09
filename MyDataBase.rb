class MyDatabase

    attr_reader :connection, :sql

    def initialize
        @connection = PG::Connection.new(host: ENV['DB_HOST'],
        user: ENV['POSTGRES_USER'],
        password: ENV['POSTGRES_PASSWORD'],
        dbname: ENV['POSTGRES_DB'])
    end

    def execute_statement(query)
        return @connection.query(query)
    end
end