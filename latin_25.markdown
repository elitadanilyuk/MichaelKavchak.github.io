---
layout: default
weight: 3
title: Латинкою-25
permalink: /poems-latin-25/
categories: latin_25
---

{%- assign sorted_posts = site.categories.latin_25 | sort: 'number' | reverse -%}
{%- for post in sorted_posts -%}
{% if post.categories contains 'delete' %}
{%- continue -%}
{% endif %}

  <div class="post-data">
    {{ post.content }}
    <h3 class="number-field">
      <a href="{{ post.url }}">
        {{ post.number }}-{{ post.edits }}
      </a>
    </h3>
    <h3 class="type-field">
      @@
    </h3>
  </div>
{%- endfor -%}
