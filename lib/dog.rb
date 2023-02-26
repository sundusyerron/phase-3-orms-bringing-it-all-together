class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        query = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                breed TEXT,
                name TEXT
            )
        SQL
        DB[:conn].query(query)
    end

    def self.drop_table
        query = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].query(query)
    end

    def save
        query = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?,?)
        SQL
        DB[:conn].query(query, self.name, self.breed)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

    # return the Ruby instance
    self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name,  breed: breed)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id:row[0],name:row[1],breed:row[2])        
    end

    def self.all
        query = <<-SQL
            SELECT * FROM dogs
        SQL
        DB[:conn].query(query).map do |row|
            new_from_db(row)
        end
    end

    def self.find_by_name(name)
        query = <<-SQL
            SELECT * FROM dogs WHERE name = ? LIMIT 1
        SQL
        DB[:conn].query(query, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find(id)
        query = <<-SQL
            SELECT * FROM dogs WHERE id = ? LIMIT 1
        SQL
        DB[:conn].query(query, id).map do |row|
            self.new_from_db(row)            
        end.first

    end



end

