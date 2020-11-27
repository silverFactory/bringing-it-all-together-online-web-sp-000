class Dog
  attr_accessor :name, :breed, :id
  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
      DB[:conn].execute(sql)
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end
  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end
  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end
  def self.new_from_db(row)
    hash = {id: row[0], name: row[1], breed: row[2]}
    dog = Dog.new(hash)
  end
  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?
    SQL
    Dog.new_from_db(DB[:conn].execute(sql, id)[0])
  end
  def self.find_or_create_by(hash)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    dog = DB[:conn].execute(sql, hash[:name], hash[:breed])
    if !dog.empty?
      dog_info = dog[0]
      dog = Dog.new_from_db(dog_info)
    else
      dog = Dog.create(hash)
    end
    dog
  end
  def self.find_by_name(name)
    Dog.new_from_db(DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0])
  end
  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
