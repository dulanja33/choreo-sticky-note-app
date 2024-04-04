import { useEffect, useState } from 'react';
import { createNote, deleteNote, fetchNotes, updateNote } from './api';
import StickyNote from './StickyNote';

interface Note {
  Id: number;
  Description: string;
}

function App() {

  const [notes, setNotes] = useState<Note[]>([]);

  useEffect(() => {
    const fetchNotesData = async () => {
      try {
        const fetchedNotes = await fetchNotes();
        setNotes(fetchedNotes);
      } catch (error) {
        console.error('Error fetching notes:', error);
      }
    };
    fetchNotesData();
  }, []);


  const handleOnUpdate = async (updatedNote: Note) => {
    const updated = await updateNote(updatedNote.Id, updatedNote.Description);
    if (updated) {
      const updatedNotes = notes.map((note) => {
        if (note.Id === updated.Id) {
          return updated;
        }
        return note;
      });
      setNotes(updatedNotes);
    }
  }

  const handleOnDelete = async (id: number) => {
    const deleted = await deleteNote(id);
    if (deleted) {
      const updatedNotes = notes.filter((note) => note.Id !== id);
      setNotes(updatedNotes);
    }
  }

  const handleOnCreate = async () => {
    const newNote = await createNote("Add note here...");
    if (newNote) {
      setNotes([...notes, newNote]);
    }
  }


  return (
    <>
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold mb-4 text-center">Sticky Notes</h1>
        {/* Form to create new notes (optional) */}
        {/* List of existing notes */}
        <div className='flex flex-wrap justify-center'>
          {notes.map((note) => (
            <StickyNote key={note.Id} note={note} onDelete={() => { handleOnDelete(note.Id) }} onUpdate={handleOnUpdate} />
          ))}
          <div className='bg-yellow-100 p-4 rounded shadow-md m-4 w-1/4 min-w-80 h-80 relative justify-center flex items-center'>
            <button className='bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded cursor-pointer'
              onClick={() => { handleOnCreate() }}
            >
              Add Note
            </button>
          </div>
        </div>

      </div>
    </>
  )
}

export default App
