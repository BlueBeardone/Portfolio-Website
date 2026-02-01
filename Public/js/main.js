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
            <li><strong>Temporal</strong> - Durable code executions</li>
        </ul>
        <div class="skills-highlight">
            <strong>Specialized in:</strong> Full-stack development
        </div>
    </div>`,

    // Enhanced History section
    `<div class="history-section">
        <h3>Education</h3>
        <ul class="history-list">
            <li>
                <strong>BelgiumCampus iTversity</strong> - Software Engineering
                <br><em>2023 - Present</em>
                <br>Studying software engineering with focus on system design and development principles
            </li>
        </ul>

        <h3>Work Experience</h3>
        <ul class="history-list">
            <li>
                <strong>VR and Drone Technologies</strong> - Software Developer
                <br><em>mid of 2025 - end of 2025</em>
                <br>Developing software solutions for VR applications and drone control systems
            </li>
            <li>
                <strong>Freelance Developer</strong>
                <br><em>2024 - Present</em>
                <br>Created custom web solutions and database applications for local businesses
            </li>
            <li>
                <strong>Internship at Eps-Mathu</strong> - Junior Developer
                <br><em>2026 - present</em>
                <br>Assisted in developing a website and database management system
            </li>
        </ul>

        <h3>Achievements</h3>
        <ul class="history-list">
            <li>Contributed to projects on GitHub</li>
            <li>Participated in 3 hackathons and a few GameJams</li>
            <li>Completed a few technical webinars on emerging technologies</li>
            <li>Completed the Temporal Fundamentals Certification</li>
        </ul>
    </div>`,

    // Enhanced About section
    `<div class="about-section">
        <p>Creative problem-solver with a passion for game development and interactive experiences.</p>
        
        <h3>Personal Interests</h3>
        <ul class="about-list">
            <li>Game Development: Working on indie game projects in Unreal Engine and Unity</li>
            <li>Technology Exploration: VR, drone tech, AI applications and new emerging technologies</li>
        </ul>

        <h3>Values</h3>
        <p>Committed to writing clean, maintainable code and creating impactful digital experiences that make a difference.</p>
        
        <h3>Currently Learning</h3>
        <ul class="about-list">
            <li>Advanced Unity development</li>
            <li>Rasberry Pi development and electronic connections</li>
            <li>Cloud computing with AWS</li>
            <li>Advanced Machine learning</li>
            <li>Temporal for building durable code that does not rely on external dependencies</li>
        </ul>
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