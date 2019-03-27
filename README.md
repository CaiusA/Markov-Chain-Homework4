Homework 3 and Homework 4
------------------

## Homework 3 - Marchov Chain Text Generator class
Coding this was relatively straightforward and not that difficult to implement. For my original idea, the first 2 words that were to be used for the trigram were the first 2 letters of the text file. After testing it out, I felt that it wouldn't be much of a random text generator if it would always get the first 2 words. So, I chose a random word first and then used a bigram to get the next word. Those 2 words were then run through the trigram until it reached the desired text length or end of a sentence depending which method it's in.

The only reoccurring error was that sometimes there were no next words based on the 2 in nextPossible. In Ruby, it doesn't give an out of bounds error, but it does return a `nil` value. It was simply fixed with
```ruby
if nextPossible[0] == nil
    nextPossible[0] = @wordBank.sample
end
```

## Homework 4 - Marchov Chain Midi Generator class
I had a lot more difficulty writing this program than homework-3. I used only [this source documentation](http://www.rubydoc.info/gems/midilib/2.0.4/MIDI) and [this repository](https://github.com/jimm/midilib/tree/master/examples) since they were the only real resources that I could find. The rubydoc was the most helpful since it had all the objects and methods available. However, there many cases where I was lost because the the classes didn't always have what methods they inherited from their parent classes. There were also methods that only said that it returns an object but doesn't specify what kind of object. The repository was helpful because I could see example programs and use parts of it in my own code. Although seeing how the code was written and the comments helped, it only helped with getting a basic understanding and not much more than that. The comments also weren't that descriptive to help me fully understand what was going on in the code.

My first idea was to create a list of notes (NoteOn and NoteOff object pairs) and input them into a new Sequence and write use that new Sequence to write into the new midi file. In the middle of implementing the initialization, I realized that it would take a lot less time and work to simply remove the note objects from each track in the sequence than to create a new sequence from scratch. At that point I created a new branch, worked on it for a while, and merged that branch into the master branch once I felt I was truly committed to that approach.

Debugging this one was a lot harder, mostly because I had no choice but to have lists nested with more lists by 3 levels (list to hold index and list of notes for each track, list of notes represented by a note pair aka [NoteOn, NoteOff]). Unlike the text generator, instead of getting a `nil` for out of bounds, it would get `[]` for the note pair. With the way the trigram works, I kept getting NoMethodError: undefined method '[]' for nil:NilClass because the note pair would be an empty list. Since the error kept pointing at the if statement within the elsif statement, I couldn't tell whether if the error was for `currentNotes` or `track`. It turned out to be both because sometimes there would be empty not pairs in `track` and `currentNotes` would sometimes try to get something from out of bounds which would mess with the comparisons.