module.exports = (app) => {
  app.on("issue_comment.created", async (context) => {
    const comment = context.payload.comment.body;
    const sender = context.payload.comment.user.login;

    if (comment.includes("/deploy")) {
      await context.octokit.issues.createComment(context.issue({
        body: `🚀 Deployment triggered by @${sender}`
      }));
    }
  });
};
