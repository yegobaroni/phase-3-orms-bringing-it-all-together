class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        DB[:conn]
        table_check_sql =  <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
          )
          SQL
        DB[:conn].execute(table_check_sql)
    end

    # .drop_table class method
    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        self.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.all
        sql = <<-SQL
            SELECT *
            FROM dogs;
        SQL

        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
        self.new(name: dog[1], breed: dog[2], id: dog[0])
    end

    def self.find(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end
    def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL

    row = DB[:conn].execute(sql, name, breed).first

    if row
      self.new_from_db(row)
    else
      self.create(name: name, breed: breed)
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs 
      SET 
        name = ?, 
        breed = ?  
      WHERE id = ?;
    SQL
    
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end