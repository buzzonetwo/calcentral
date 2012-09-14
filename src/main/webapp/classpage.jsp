<%@ taglib tagdir="/WEB-INF/tags" prefix="tags" %>

<tags:head/>

<body class="cc-page-classpage">
	<tags:header/>
	<tags:topnavigation/>
	<div class="cc-container-main" role="main">
		<!-- Page specific HTML -->
		<tags:lhclasspagenavigation/>
		<div class="cc-page-classpage-container cc-container-main-right">


		<script id="cc-page-classpage-template" type="text/x-handlebars-template">
			<div class="cc-container-widget cc-page-classpage-header">
				<div class="cc-widget-title">
					<h2>UC Berkeley Course</h2>
				</div>
				<div class="cc-widget-main">
					{{>header}}
				</div>
			</div>
			<div class="cc-container-widget cc-page-classpage-description" id="cc-page-classpage-description">
				<div class="cc-widget-title">
					<h2>Course Catalog Description</h2>
				</div>
				<div class="cc-widget-main">
					{{>description}}
				</div>
			</div>

			<div class="cc-container-widget cc-page-classpage-courseinfo" id="cc-page-classpage-courseinfo">
				<div class="cc-widget-title">
					<h2>Course Info</h2>
				</div>
				<div class="cc-widget-main">
					{{>courseInfo}}
				</div>
			</div>
			<div class="cc-container-widget cc-page-classpage-instructor">
				<div class="cc-widget-title">
					<h2>Instructor</h2>
				</div>
				<div class="cc-widget-main">
					{{>instructor}}
				</div>
			</div>
			<div class="cc-container-widget cc-page-classpage-sections">
				<div class="cc-widget-title">
					<h2>Lecture &amp; Section Details</h2>
				</div>
				<div class="cc-widget-main">
					{{>sections}}
				</div>
			</div>
		</script>
		<script id="cc-page-classpage-header-template" type="text/x-handlebars-template">
			<h2>{{classtitle}}</h2>
			<h3>{{courseinfo.department}} {{courseinfo.coursenum}} : {{courseinfo.term}} {{courseinfo.year}}</h3>
		</script>

		<script id="cc-page-classpage-description-template" type="text/x-handlebars-template">
			{{description}}
		</script>

		<script id="cc-page-classpage-courseinfo-template" type="text/x-handlebars-template">
			{{#with courseinfo}}
			<ul class="cc-page-classpage-list">
				<li><span>Format:</span><span>{{#if format}}{{format}}{{else}}<em>Not available</em>{{/if}}</span></li>
				<li><span>Units:</span><span>{{#if units}}{{units}}{{else}}<em>Not available</em>{{/if}}</span></li>
				<li><span>Semesters offered:</span><span>{{#if semesters_offered}}{{semesters_offered}}{{else}}<em>Not available</em>{{/if}}</span></li>
				<li><span>Requirements:</span><span>{{#if requirements}}{{requirements}}{{else}}<em>Not available</em>{{/if}}</span></li>
				<li><span>Grading:</span><span>{{#if grading}}{{grading}}{{else}}<em>Not available</em>{{/if}}</span></li>
				<li><span>Prerequisites:</span><span>{{#if prereqs}}{{prereqs}}{{else}}<em>Not available</em>{{/if}}</span></li>
			</ul>
			{{/with}}
		</script>

		<script id="cc-page-classpage-instructor-template" type="text/x-handlebars-template">
			<ul class="cc-page-classpage-instructor-item">
			{{#if instructors}}
				{{#each instructors}}
					<li>
						{{#instrimg}}
							<img class="cc-page-classpage-instructor-profile" src="{{img}}" />
						{{/instrimg}}
						{{^instrimg}}
							<img class="cc-page-classpage-instructor-profile" src="/img/myb/default_User_icon_100x100.png" />
						{{/instrimg}}

						<div class="cc-page-classpage-instructor-heading">
						{{#if name}}
							<a href="https://calnet.berkeley.edu/directory/details.pl?uid={{id}}">{{name}}</a>
						{{else}}
							<em>Instructor name is not available</em>
						{{/if}}
						{{#if title}}
							<div>{{title}}</div>
						{{/if}}
						</div>
						<ul class="cc-page-classpage-list">
							{{#if url}}<li><span>Website:</span><span><a href="{{url}}">{{url}}</a></span></li>{{/if}}
							{{#if phone}}<li><span>Phone #:</span><span>{{phone}}</span></li>{{/if}}
							{{#if office}}<li><span>Office:</span><span>{{office}}</span></li>{{/if}}
						</ul>
					</li>
				{{/each}}
			{{else}}
				Instructor names not found
			{{/if}}
			</ul>
		</script>

		<script id="cc-page-classpage-sections-template" type="text/x-handlebars-template">
		{{#if sections}}
		<span id="classpages_showhideall">
			<button id="classpages_expandall" class="cc-link-button">Expand all</button> |
			<button id="classpages_collapseall" class="cc-link-button">Collapse all</button>
		</span>
		<table id="classpages_section_results">
			<thead>
				<tr>
					<th class="classpages_sections_col1">Class Meeting</th>
					<th>CCN</th>
					<th>Instructor</th>
					<th>Enrolled</th>
					<th>Waitlist</th>
					<th class="classpages_sections_timecol">Time</th>
					<th class="classpages_sections_loccol">Location</th>
				</tr>
			</thead>
			<tbody>
				{{#each sections}}
				<tr class="classpages_classrow">
					<td>
						<button class="classpages_sections_arrow cc-link-button" id="sectionarrow-{{coursenum}}"></button>
						<span class="classpages_section_title_warrow">
							<strong>{{section}}</strong></span>
						</span>
					</td>

					<td>
						{{coursenum}}
					</td>

					<td class="classpages_sections_instrnames">
						{{#each instructors}}
							{{#if id}}
								<a href="/~{{id}}">{{name}}</a>
							{{else}}
								{{name}}
							{{/if}}
						{{/each}}
					</td>

					<%-- Mustache doesnt allow tests like 'if this AND that' so we double nest the tests --%>
					<td>{{#if enrolled_cur}}
							{{#if enrolled_max}}
								{{enrolled_cur}}/{{enrolled_max}}
							{{/if}}
						{{/if}}
					</td>

					<td>
						{{#if waitlist}}
							Y
						{{/if}}
					</td>

					<td class="classpages_sections_timecol">
						{{#if time }}
							{{time}}
						{{/if}}
					</td>

					<td class="classpages_sections_timecol">
						{{#if location }}
							{{location}}
						{{/if}}
					</td>
				</tr>

				<tr class="classpages_metadata">
					<td colspan="5">
						<table class="classpages_sections_table_inner">
							{{#if note}}
							<tr>
								<td class="classpages_sections_col1 classpages_table_label">
									Note:
								</td>

								<td>
									{{note}}
								</td>
							</tr>
							{{/if}}

							<tr>
								<td class="classpages_sections_col1 classpages_table_label">
									Final exam:
								</td>

								<td>
									{{#if final_datetime}}{{final_datetime}}
										{{#if final_coords}}
											<a href="http://maps.google.com/maps?daddr={{final_coords}}&l=en&dirflg=w&t=m&z=17" target="_blank">in {{final_location}}</a>
										{{else}}
											<em>Not available</em>
										{{/if}}
									{{else}}
											<em>Not available, location unknown</em>
									{{/if}}

									{{#if final_note}}
										<a href="#" class="show_note" data-note="{{final_note}}">[Note]</a>
									{{/if}}
								</td>
							</tr>

							{{#if midterm_datetime}}
							<tr>
								<td class="classpages_sections_col1 classpages_table_label">
									Mid-term:
								</td>

								<td>
									{{#if midterm_datetime}}{{midterm_datetime}}
										{{#if midterm_coords}}
											<a href="http://maps.google.com/maps?daddr={{midterm_coords}}&l=en&dirflg=w&t=m&z=17" target="_blank">in {{midterm_location}}</a>
										{{/if}}
									{{else}}
										<em>Not available</em>
									{{/if}}
									{{#if midterm_note}}
										<a href="#" class="show_note" data-note="{{midterm_note}}">[Note]</a>
									{{/if}}
								</td>
							</tr>
							{{/if}}

							{{#if restrictions}}
							<tr>
								<td class="classpages_sections_col1 classpages_table_label">
									Restrictions:
								</td>

								<td>
									{{restrictions}}
								</td>
							</tr>
							{{/if}}

						</table>
					</td>

					<td colspan="2">
						{{#if coords}}
							<a href="http://maps.google.com/maps?daddr={{coords}}&l=en&dirflg=w&t=m&z=17" target="_blank"><img src="http://maps.googleapis.com/maps/api/staticmap?center={{coords}}&zoom=16&size=200x200&maptype=roadmap&markers=color:blue%7C{{coords}}&sensor=false" /></a>
						{{else}}
							<img src="/img/myb/classpages_map_not_available.png" />
						{{/if}}
					</td>
				</tr>

				{{/each}}
			</tbody>
		{{else}}
			<em>Not available</em>
		{{/if}}
		</script>

		</div>
		<!-- END Page specific HTML -->
		<br class="clearfix" />
	</div>
	<tags:footer/>
</body>
</html>