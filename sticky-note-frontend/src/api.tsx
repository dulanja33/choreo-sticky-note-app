declare global {
   interface Window {
     configs: {
       apiUrl: string;
     };
   }
}

const BASE_URL = window.configs.apiUrl ? window.configs.apiUrl : "http://localhost:8080";


export const fetchNotes = async () => {
  const response = await fetch(`${BASE_URL}/getNotes`);
  if (!response.ok) {
    throw new Error('Failed to fetch notes');
  }
  return await response.json();
};

export const createNote = async (content: any) => {
  const response = await fetch(`${BASE_URL}/addNote`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ "description": content }),
  });
  if (!response.ok) {
    throw new Error('Failed to create note');
  }
  return await response.json();
};

export const updateNote = async (id: number, content: any) => {
  const response = await fetch(`${BASE_URL}/updateNote/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ "description": content }),
  });
  if (!response.ok) {
    throw new Error('Failed to update note');
  }
  return await response.json();
}

export const deleteNote = async (id: number) => {
    const response = await fetch(`${BASE_URL}/deleteNote/${id}`, {
        method: 'DELETE',
    });
    if (!response.ok) {
        throw new Error('Failed to delete note');
    }
    return true;
}
