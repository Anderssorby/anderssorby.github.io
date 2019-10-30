---
layout: default
permalink: /
---
<h1>Welcome to my homepage</h1>

It might someday be full of interesting posts about various topics. See my [CV here](/files/English_CV.pdf).

Topics I'm interested in:

 * Deep learing and AI
 * Machine learning and Data Science in general
 * Programming and thereunder Functional Programming
 * Mathematics which includes things like Category Theory, Topology, Statistics and generally anything logically structured.
 * Philosophy - what should we do and are we doing the right thing? What does really make sense?
 * Using knowledge to make the world a better place for everyone.

I'm also an eager reader of the webcomics [Existential Comics](https://existentialcomics.com) and [SMBC - Saturday Morning Breakfast Cereal](https://smbc-comics.com).

<h1>Posts</h1>
<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>

