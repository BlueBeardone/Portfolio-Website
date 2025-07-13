const descriptions = [
    `<div class='skills-description'>
        <h3>Technical Proficiencies</h3>
        <ul class='skills-list'>
            <li><strong>C# & .NET</strong> - Advanced application development</li>
            <li><strong>Web Technologies</strong> - HTML5, CSS3, JavaScript/ES6+</li>
            <li><strong>Database Systems</strong> - MySQL, SQL Server, MongoDB</li>
            <li><strong>Python</strong> - Data analysis & automation</li>
            <li><strong>Game Development</strong> - Unity, Unreal Engine</li>
            <li><strong>Frontend Frameworks</strong> - React, Vue.js</li>
            <li><strong>Backend Technologies</strong> - Node.js, Express</li>
            <li><strong>Cloud Platforms</strong> - Azure, AWS</li>
            <li><strong>DevOps</strong> - Docker, CI/CD pipelines</li>
            <li><strong>Emerging Tech</strong> - VR/AR, Drone Programming</li>
        </ul>
        <div class="skills-highlight">
            <strong>Specialized in:</strong> Full-stack development, game design, and immersive technology solutions
        </div>
    </div>`
];

function ChangeDescription(index) {
    const descElement = document.getElementById('description');
    descElement.classList.remove('active');
    
    setTimeout(() => {
        descElement.innerHTML = descriptions[index];
        descElement.classList.add('active');
    }, 300);
}

// Initialize with first description
document.addEventListener('DOMContentLoaded', () => ChangeDescription(0));

// Add scroll animation
window.addEventListener('scroll', () => {
    document.documentElement.style.setProperty('--scroll', window.pageYOffset / 
        (document.documentElement.scrollHeight - window.innerHeight));
});