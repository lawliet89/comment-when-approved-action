const { promises: fs } = require("fs");
const Octokit = require("@octokit/rest");

function checkEnvVars() {
    if (!process.env.GITHUB_TOKEN) {
        throw new Error("Set the GITHUB_TOKEN env variable.");
    }

    if (!process.env.GITHUB_REPOSITORY) {
        throw new Error("Set the GITHUB_REPOSITORY env variable.");
    }

    if (!process.env.GITHUB_EVENT_PATH) {
        throw new Error("Set the GITHUB_EVENT_PATH env variable.");
    }

    if (!process.env.COMMENT) {
        throw new Error("Set the COMMENT env variable.");
    }

    if (!process.env.REACTION) {
        console.warn("Warning: REACTION not set; default to hooray.");
        process.env.REACTION = "hooray";
    }
}

async function checkLabels(octokit, number, owner, repo) {
    const { data: { labels } } = await octokit.pulls.get({
        owner,
        repo,
        pull_number: number
    });

    const triggerLabels = process.env.TRIGGER_LABELS ? process.env.TRIGGER_LABELS.split(",") : [];
    if (triggerLabels.length === 0) {
        return false;
    }

    for (let label of labels) {
        if (triggerLabels.indexOf(label.name) !== -1) {
            return true;
        }
    }
    return false;
}

async function commentWhenApproved(octokit, number, owner, repo) {
    // Check whether this PR has any of the desired labels
    const hasTrigger = await checkLabels(octokit, number, owner, repo);
    if (!hasTrigger) {
        console.warn("Ignoring pull request without trigger labels");
        process.exit();
    }

    // Get all reviews
    const { data: reviews } = await octokit.pulls.listReviews({ owner, repo, pull_number: number });
    const lastReview = reviews[reviews.length - 1];
    if (lastReview.state === "APPROVED") {
        // Create comment
        const { data: { id: comment_id } } = await octokit.issues.createComment({
            owner,
            repo,
            issue_number: number,
            body: process.env.COMMENT
        });

        // React to that comment
        await octokit.reactions.createForIssueComment({
            owner,
            repo,
            comment_id,
            content: process.env.REACTION
        });
    }
}

async function main() {
    const eventDataStr = await fs.readFile(process.env.GITHUB_EVENT_PATH, { encoding: "utf8" });
    const eventData = JSON.parse(eventDataStr);

    const { action, review: { state }, pull_request: { number } } = eventData;
    const [owner, repo] = process.env.GITHUB_REPOSITORY.split("/");
    const octokit = Octokit({
        auth: process.env.GITHUB_TOKEN,
        // Need this preview for the reaction API
        // https://developer.github.com/v3/reactions/#create-reaction-for-an-issue-comment
        previews: ["squirrel-girl-preview"],
    });

    if (action === "submitted" && state === "approved") {
        await commentWhenApproved(octokit, number, owner, repo);
    } else {
        console.warn(`Ignoring event ${action}/${state}`);
    }
}

checkEnvVars();
main();
