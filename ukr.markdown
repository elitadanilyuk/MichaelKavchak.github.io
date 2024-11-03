---
layout: default
weight: 1
title: Українською
permalink: /poems-ukr/
categories: ukr
---

{%- assign sorted_posts = site.categories.ukr | sort: 'number' | reverse -%}
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
