const descriptions = [
    "Proficient in modern web technologies including JavaScript, HTML5, and CSS3. Experienced with frameworks like React and Vue.js. Strong background in backend development with Node.js and Python. Passionate about creating efficient, scalable solutions with clean code architecture.",
    "3+ years experience in software development. Currently working on innovative SaaS solutions. Previously contributed to open-source projects and participated in hackathons. Continuously learning and adapting to new technologies in the fast-paced tech industry.",
    "Creative problem-solver with a passion for game development and interactive experiences. When not coding, I enjoy contributing to indie game projects and exploring new technologies. Committed to writing maintainable code and creating impactful digital experiences."
];

function ChangeDescription(index) {
    const descElement = document.getElementById('description');
    descElement.classList.remove('active');
    
    setTimeout(() => {
        descElement.textContent = descriptions[index];
        descElement.classList.add('active');
    }, 300);
}

// Initialize with first description
window.onload = () => ChangeDescription(0);

// Add scroll animation
window.addEventListener('scroll', () => {
    document.documentElement.style.setProperty('--scroll', window.pageYOffset / 
        (document.documentElement.scrollHeight - window.innerHeight));
});