class Dog
  attr_accessor :id, :name, :breed

  def initialize(attr_hash)
    attr_hash.each {|key,value| self.send("#{key}=",value)}
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
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs(name, breed) VALUES(?,?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.new_from_db(attributes)
    dog = self.new(id:attributes[0],name:attributes[1],breed:attributes[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id=?;
    SQL

    attributes = DB[:conn].execute(sql,id)[0]
    self.new_from_db(attributes)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    attributes = DB[:conn].execute(sql,name)[0]
    self.new_from_db(attributes)
  end

  def self.find_or_create_by(attributes)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    dog = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

    if dog.empty?
      dog = self.create(attributes)
    else
      array = dog[0]
      data = {:id => array[0], :name => array[1], :breed => array[2] }
      dog = self.new(data)
    end
  end

  def update
    DB[:conn].execute('UPDATE dogs SET name = ?, breed = ? WHERE id = ?;', self.name, self.breed, self.id)
  end
end
