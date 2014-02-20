describe 'ResponseCommentShowView', ->
    beforeEach ->
        # set up the container for the response to go in
        setFixtures """
        <ol class="responses"></ol>
        <script id="response-comment-show-template" type="text/template">
            <div id="comment_<%- id %>">
            <div class="response-body"><%- body %></div>
            <div class="discussion-flag-abuse notflagged" data-role="thread-flag" data-tooltip="report misuse">
            <i class="icon"></i><span class="flag-label"></span></div>
            <div style="display:none" class="discussion-delete-comment action-delete" data-role="comment-delete" data-tooltip="Delete Comment" role="button" aria-pressed="false" tabindex="0">
              <i class="icon icon-remove"></i><span class="sr delete-label">Delete Comment</span></div>
            <p class="posted-details">&ndash;posted <span class="timeago" title="<%- created_at %>"><%- created_at %></span> by
            <% if (obj.username) { %>
            <a href="<%- user_url %>" class="profile-link"><%- username %></a>
            <% } else {print('anonymous');} %>
            </p>
            </div>
        </script>
        """

        # set up a model for a new Comment
        @comment = new Comment {
                id: '01234567',
                user_id: '567',
                course_id: 'edX/999/test',
                body: 'this is a response',
                created_at: '2013-04-03T20:08:39Z',
                abuse_flaggers: ['123']
                roles: []
        }
        @view = new ResponseCommentShowView({ model: @comment })
        spyOn(@view, "convertMath")

    it 'defines the tag', ->
        expect($('#jasmine-fixtures')).toExist
        expect(@view.tagName).toBeDefined
        expect(@view.el.tagName.toLowerCase()).toBe 'li'

    it 'is tied to the model', ->
        expect(@view.model).toBeDefined()

    describe 'rendering', ->

        beforeEach ->
            spyOn(@view, 'renderAttrs')
            spyOn(@view, 'markAsStaff')

        it 'produces the correct HTML', ->
            @view.render()
            expect(@view.el.innerHTML).toContain('"discussion-flag-abuse notflagged"')

        it 'can be flagged for abuse', ->
            @comment.flagAbuse()
            expect(@comment.get 'abuse_flaggers').toEqual ['123', '567']

        it 'can be unflagged for abuse', ->
            temp_array = []
            temp_array.push(window.user.get('id'))
            @comment.set("abuse_flaggers",temp_array)
            @comment.unflagAbuse()
            expect(@comment.get 'abuse_flaggers').toEqual []

    describe 'comment deletion', ->

        it 'triggers the delete event when the delete icon is clicked', ->
            DiscussionUtil.loadRoles []
            @comment.updateInfo {ability: {'can_delete': true}}
            triggerTarget = jasmine.createSpy()
            @view.bind "comment:_delete", triggerTarget
            @view.render()
            @view.$el.find('.action-delete').click()
            expect(triggerTarget).toHaveBeenCalled()
