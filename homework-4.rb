# Name: Caius Arias
# Program: homework-4.rb
# Description: Uses Marchov chains to generate music based on previously played notes.
#                       Works best with midi files that aren't very long or with few tracks. Otherwise
#                       it may take a fairly while to create the new remixed version.
# Ruby version: ruby 2.4.3p205 (2017-12-14 revision 61247) [x86_64-linux]
#
# Heavily references example programs from https://github.com/jimm/midilib/tree/master/examples
# besides the library documentation for reading, writing, and accessing portions of midi files

class MarchovChainMidiGenerator
  
  require 'midilib/sequence'
  require 'midilib/consts'
  include MIDI
  
  def initialize(song)
    @song = song
    
    #read file and gather necessary info section
    @seq = MIDI::Sequence.new()
    File.open(@song, 'rb') do |file|
      @seq.read(file)
    end
    @trackInfo = []
    
    #Gather essential info about eack track from the original midi file
    @seq.each_with_index do |track, i|

      #list of notes in each track
      notes = []
      @trackInfo << [i, notes] 
      
      #gather notes (NoteOn NoteOff pairs)
      track.events.each_with_index do |event, j|
        note = []
        if event.instance_of? NoteOn
          note << event
          note << track.events[j+1]
          notes << note
        end
      end

      #clear note events
      track.events.each do |event|
        if (event.instance_of? NoteOn) or (event.instance_of? NoteOff)
          track.events.delete(event)
        end
      end
    end

    #gets rid of tracks without any notes as well as empty note pairs
    @trackInfo.delete_if {|track| track[1].count == 0}
    @trackInfo.each do |track|
      track[1].delete([])        
    end
  end

  def generate
    #create a generated song based on original file section
    @trackInfo.each do |track|
      numNotesLeft = track[1].count
      newNotesArr = [] #equivalent to output
      
      #get a random note pair
      currentNotes = [track[1].sample]

      numNotesLeft -= 1
      
      #bigram based on note pitch
      possibleNotes = []
      track[1].each_with_index do |notePair, i| #notePair is wordBank
        if currentNotes[0][0].note_to_s == notePair[0].note_to_s
          possibleNotes << track[1][i + 1]
        end
      end

      #gets rid of nil values
      possibleNotes.compact!

      #if the bigram couldn't get a next note
      if possibleNotes.count == 0
        possibleNotes << track[1].sample
      end
      
      currentNotes << possibleNotes.sample
      currentNotes.compact!
      numNotesLeft -= 1

      #trigram
      until numNotesLeft == 0
        possibleNotes = []
        track[1].each_with_index do |notePair, i|

          #if out of bounds, choose a random note
          if track[1][i + 1] == nil or track[1][i + 2] == nil
            possibleNotes << track[1].sample

          #trigram note pitch checking
          elsif (currentNotes[0][0].note_to_s == notePair[0].note_to_s)
            if(currentNotes[1][0].note_to_s == track[1][i + 1][0].note_to_s)
              possibleNotes << track[1][i+2]
            end
          end
        end
        
        newNotesArr << currentNotes.shift
        currentNotes << possibleNotes.sample
        numNotesLeft -= 1
      end

      #add last 2 notes to track
      newNotesArr += currentNotes
      newNotesArr.flatten!.each do |note|
        @seq.tracks[track[0]].events << note
      end
    end
    
    #write song to new midi file section
    File.open("#{@song[0..-5]}_remix.mid", "wb") {|file| @seq.write(file)}    
  end
  
  def to_s
    puts "Loaded #{@song} and ready to create a cool new song"
  end

  def inspect
    puts "Original: #{@song}"
    puts "Number of tracks: #{@seq.tracks.count}"
  end
  
end
