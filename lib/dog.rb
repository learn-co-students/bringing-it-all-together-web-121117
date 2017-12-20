require 'pry'
class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    attributes.each {|k,v| self.send("#{k}=", v)}
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = 'DROP TABLE IF EXISTS dogs;'
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute('SELECT * FROM dogs ORDER BY id DESC LIMIT 1;')[0][0]
      self
    end
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
    dog
  end

  def update
    DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?;', self.name, self.breed, self.id)
  end

  def self.new_from_db(attributes)
    hash = {:id => attributes[0], :name => attributes[1], :breed => attributes[2]}
    dog = self.new(hash)
  end

  def self.find_by_name(name)
    sql = 'SELECT * FROM dogs WHERE name = ? LIMIT 1'
    DB[:conn].execute(sql, name).map {|row| self.new_from_db(row)}.first
  end

  def self.find_by_id(id)
    sql = 'SELECT * FROM dogs WHERE id = ? LIMIT 1'
    DB[:conn].execute(sql, id).map {|row| self.new_from_db(row)}.first
  end

  def self.find_or_create_by(attributes)
    sql = 'SELECT * FROM dogs WHERE name = ? AND breed = ?;'
    dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed])
    if !dog.empty?
      dog_array = dog[0]
      dog_data = {:id => dog_array[0], :name => dog_array[1], :breed => dog_array[2] }
      dog = self.new(dog_data)
    else
      dog = self.create(attributes)
    end
  end



end
