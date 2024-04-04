import { GrClose } from "react-icons/gr";
import { FaEdit } from "react-icons/fa";
import { AiOutlineSave } from "react-icons/ai";
import { useRef, useState } from "react";


interface Note {
    Id: number;
    Description: string;
}

const StickyNote = ({ note, onDelete, onUpdate }: { note: Note, onDelete: () => void, onUpdate: (note: Note) => void }) => {

    const [newNote, setNewNote] = useState(note);
    const [isEditing, setIsEditing] = useState(false);
    const inputRef = useRef<HTMLTextAreaElement>(null);

    const handleInputChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
        const updatedNote: Note = { ...newNote, Description: e.target.value };
        // Update the note
        setNewNote(updatedNote);
    };

    const handleOnUpdate = () => {
        if (isEditing) {
            setIsEditing(false);
            onUpdate(newNote);

        } else {
            setIsEditing(true);
            if (inputRef.current) {
                inputRef.current.focus();
                const len = inputRef.current.value.length;
                inputRef.current.setSelectionRange(len, len);
            }
        }
    }

    return (
        <div className="bg-yellow-100 p-4 rounded shadow-md m-4 w-1/4 min-w-80 h-80 relative">
            <div className="mt-4 overflow-scroll h-60">
                <textarea
                    className=" bg-yellow-100 rounded px-2 py-1 mr-2 h-full w-11/12 focus:outline-none resize-none"
                    rows={10}
                    ref={inputRef}
                    maxLength={300}
                    readOnly={!isEditing}
                    placeholder="Enter your note here..."
                    value={newNote.Description}
                    onChange={handleInputChange}
                    onKeyDown={(e) => { if (e.key === 'Enter' && !e.shiftKey) handleOnUpdate() }}
                    onDoubleClick={() => { if (!isEditing) handleOnUpdate() }}
                />
            </div>
            <div className="absolute top-0 right-0 flex items-center">
                <button
                    className="text-blue-500 hover:text-blue-700 focus:outline-none mt-2 mr-2"
                    onClick={handleOnUpdate}
                >
                    {!isEditing ? <FaEdit className="w-5 h-5" /> : <AiOutlineSave className="w-5 h-5" />}
                </button>
                <button
                    className="text-red-500 hover:text-red-700 focus:outline-none mr-2 mt-2"
                    onClick={onDelete}
                >
                    <GrClose className="w-5 h-5" />
                </button>
            </div>
        </div>
    );
};

export default StickyNote