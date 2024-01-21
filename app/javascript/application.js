// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

document.addEventListener('DOMContentLoaded', () => {
  const searchForm = document.getElementById('search-form');
  const searchInput = document.getElementById('search-input');
  const suggestionsDiv = document.getElementById('suggestions');
  const formActionPath = searchForm.getAttribute('data-path');
  let timeout = null;

  searchInput.addEventListener('keyup', (event) => {
    if (event.key === 'Enter') {
      event.preventDefault();
    } else {
      clearTimeout(timeout);
      timeout = setTimeout(() => {
        const query = searchInput.value.trim();
        if (query) {
          fetchSuggestions(query);
        }
      }, 300);
    }
  });

  searchForm.addEventListener('submit', (event) => {
    event.preventDefault();
    const query = searchInput.value.trim();
    if (query) {
      sendSearchQuery(query);
    }
  });

  function fetchSuggestions(query) {
    fetch(`/searches/suggestions?query=${encodeURIComponent(query)}`)
    .then(response => response.json())
    .then(data => {
      updateSuggestions(data.suggestions);
    });
  }

  function updateSuggestions(suggestions) {
    suggestionsDiv.innerHTML = '';
    suggestions.forEach(suggestion => {
      const div = document.createElement('div');
      div.textContent = suggestion;
      div.className = 'suggestion-item';
      div.onclick = () => {
        searchInput.value = suggestion;
      };
      suggestionsDiv.appendChild(div);
    });
  }

  function sendSearchQuery(query) {
    fetch(formActionPath, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ search: { content: query } })
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        console.log('Search successful:', data.query);
      } else {
        console.error('Search error');
      }
    });
  }
});
