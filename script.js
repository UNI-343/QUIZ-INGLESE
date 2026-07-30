// ---- Carica e mostra le domande ----
// Prende l'array globale allQuestions (deve esistere)
async function loadQuestions() {
  // Mischia e prendi 30 domande casuali (se l'array ha meno di 30 prende tutte)
  const shuffled = allQuestions.sort(() => 0.5 - Math.random());
  return shuffled.slice(0, Math.min(30, shuffled.length));
}

function renderQuiz(questions) {
  const container = document.getElementById('quiz-container');
  container.classList.remove('quiz-ready');
  container.innerHTML = '';

  const fragment = document.createDocumentFragment();

  questions.forEach((q, index) => {
    const div = document.createElement('div');
    div.classList.add('question');

    // testo della domanda (campo: domanda)
    let html = `<p><strong>${index + 1}.</strong> ${q.domanda}</p>`;

    // immagine (campo: immagine) — segue lo stile del progetto A
    if (q.immagine && q.immagine !== "none" && q.immagine !== null) {
      html += `<img src="${q.immagine}" alt="immagine domanda" class="quiz-image" data-img="${q.immagine}">`;
    }

    // opzioni (campo: opzioni)
    html += `<div class="options">`;
    q.opzioni.forEach((opt, i) => {
      // ogni label mantiene input radio e testo (stessa modalità visuale del Progetto A)
      html += `
        <label class="option">
          <input type="radio" name="question-${index}" value="${i}">
          <span class="option-text">${opt}</span>
        </label>
      `;
    });
    html += `</div>`;

    div.innerHTML = html;
    fragment.appendChild(div);
  });

   container.appendChild(fragment);
   
  // se KaTeX è disponibile, renderizza le formule dentro il container
  if (typeof renderMathInElement === "function") {
    try {
      renderMathInElement(container, {
        delimiters: [
          {left: "$$", right: "$$", display: true},
          {left: "$", right: "$", display: false}
        ],
        throwOnError: false
      });
    } catch (e) {
      // se qualcosa va storto non blocchiamo la pagina
      console.warn("KaTeX render error:", e);
    }
  }

  setupImageModal();

  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
        container.classList.add("quiz-ready");
    });
  });
 }

function setupImageModal() {
  const modal = document.getElementById('image-modal');
  const modalImg = document.getElementById('modal-img');
  const closeBtn = document.querySelector('.close');

  // click sulle immagini per ingrandire
  document.querySelectorAll('.quiz-image').forEach(img => {
    img.addEventListener('click', () => {
      modal.style.display = 'block';
      modalImg.src = img.dataset.img;
    });
  });

  // chiudi modal
  closeBtn.onclick = () => (modal.style.display = 'none');
  modal.onclick = e => { if (e.target === modal) modal.style.display = 'none'; };
}

// ---- Valutazione ----
// Segue la stessa logica del Progetto A: colora sempre la risposta corretta; se utente sbaglia colora la sua come wrong.
// Usa campo 'corretta' come indice corretto
function evaluateQuiz(questions) {
  const questionDivs = document.querySelectorAll('.question');
  let score = 0;

  questionDivs.forEach((div, index) => {
    const options = div.querySelectorAll('.option');
    let selected = -1;

    options.forEach((opt, i) => {
      const input = opt.querySelector('input');
      if (input.checked) selected = i;

      // Colora sempre la corretta (campo: corretta)
      if (i === questions[index].corretta) opt.classList.add('correct');

      // Se l'utente ha sbagliato, colora la sua come wrong
      if (selected === i && i !== questions[index].corretta) {
        opt.classList.add('wrong');
      }
    });

    if (selected === questions[index].corretta) score++;
  });

  document.getElementById('result').textContent =
    `Hai risposto correttamente a ${score} su ${questions.length} domande.`;
}

// ---- Eventi ----
document.getElementById('submit-btn').addEventListener('click', () => {
  evaluateQuiz(window.quizQuestions);
});

// Carica e renderizza subito
loadQuestions().then(qs => {
  window.quizQuestions = qs;
  renderQuiz(qs);
});

// ---- Spazii bianchi ----
window.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('blank[len]').forEach(el => {
      const n = parseInt(el.getAttribute('len'), 10);
      el.style.width = `${n * 2}ch`;
      el.textContent = '\u00A0'; // spazio invisibile per mostrare il background
  });
});
