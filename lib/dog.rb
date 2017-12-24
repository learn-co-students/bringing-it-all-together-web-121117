class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  #instance methods
  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES(?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  # class methods

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql,name)[0]
    new_dog = Dog.new_from_db(row)
    new_dog
  end

  def self.find_or_create_by(attr_hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    row = DB[:conn].execute(sql,attr_hash[:name], attr_hash[:breed])[0]
    if row == nil
      new_dog = Dog.create(attr_hash)
      new_dog
    else
      new_dog = Dog.new_from_db(row)
      new_dog
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    self.new_from_db(row)
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name: row[1],breed: row[2],id: row[0])
    new_dog
  end

  def self.create(attr_hash)
    new_dog = Dog.new(attr_hash)
    new_dog.save
  end

  def self.create_table
    self.drop_table
    sql = <<-SQL
      CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL
    DB[:conn].execute(sql)
  end



  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

end
