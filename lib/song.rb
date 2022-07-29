class Song

  attr_accessor :name, :album, :id

  def initialize(name:, album:, id: nil)
    @id = id
    @name = name
    @album = album
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS songs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        album TEXT
      )
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    # insert the song
    DB[:conn].execute(sql, self.name, self.album)

    # get the song ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, album:)
    song = Song.new(name: name, album: album)
    song.save
  end

  def self.new_from_db(arr)
    Song.new(id: arr[0], name: arr[1], album: arr[2])
  end

  def self.all
    sql = 
    <<-SQL
    SELECT * FROM songs;
    SQL
    songs = DB[:conn].execute(sql)
    songs.map do |s|
      Song.new(id:s[0], name: s[1], album: s[2])
    end
  end

  def self.find_by_name(name)
    sql = 
    <<-SQL
    SELECT * FROM songs 
    WHERE 
    songs.name = "#{name}"
    SQL
    song = DB[:conn].execute(sql)[0]
    self.new_from_db(song)
  end

end
