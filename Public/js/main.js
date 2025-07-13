const descriptions = [
    `<div class='skills-description'>
        Proficient in core development technologies including:
        <ul class='skills-list'>
            <li>C#</li>
            <li>HTML, CSS, JavaScript</li>
            <li>MySQL, SQL & Access</li>
            <li>Python</li>
        </ul>
        Experienced in building full-stack applications and database-driven solutions.
    </div>`,
    `Studied software engineering at BelgiumCampus iTversity, gaining strong foundational knowledge in system design and development principles. 3+ years experience in software development with hands-on project work. Currently working on VR and Drone Technologies. Contributed to open-source projects, participated in hackathons and GameJams and I have also joined many different webinars to stay up to date with the ever evolving technology.`,
    `Creative problem-solver with a passion for game development and interactive experiences. When not coding, I enjoy contributing to indie game projects and exploring new technologies. Committed to writing maintainable code and creating impactful digital experiences.`
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