const badgeContainer = document.getElementById('badge-container');
const photo = document.getElementById('background-img');
const rank = document.getElementById('rank');
const name = document.getElementById('name');

let hideTimer = null;

function setValue(element, value, fallback = '') {
    element.textContent = value && String(value).trim() !== '' ? String(value) : fallback;
}

function showBadge(data, hideAfter) {
    document.body.style.display = document.body.classList.contains('preview-mode') ? 'flex' : 'block';
    badgeContainer.style.display = 'block';

    setValue(rank, data.rank);
    setValue(name, data.name);

    if (data.photo && String(data.photo).trim() !== '') {
        photo.src = data.photo;
    } else {
        photo.src = 'img/none.png';
    }

    if (hideTimer) {
        clearTimeout(hideTimer);
    }

    const delay = Number(hideAfter);
    if (Number.isFinite(delay) && delay > 0) {
        hideTimer = setTimeout(() => {
            badgeContainer.style.display = 'none';
            document.body.style.display = 'none';
        }, delay);
    }
}

photo.addEventListener('error', () => {
    photo.src = 'img/none.png';
});

window.addEventListener('message', (event) => {
    if (!event.data || event.data.type !== 'displayBadge' || !event.data.data) {
        return;
    }

    showBadge(event.data.data, event.data.hideAfter);
});

if (window.__UK_BADGE_PREVIEW__ && window.__UK_BADGE_PREVIEW__.data) {
    document.body.classList.add('preview-mode');
    showBadge(window.__UK_BADGE_PREVIEW__.data, window.__UK_BADGE_PREVIEW__.hideAfter);
}
