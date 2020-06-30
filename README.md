# Analyzing story cycle time from Pivotal Tracker

It is important to understand how much time your team is working on a given feature set so that you can do cost/benefit analysis on the work. I will generally review this once a quarter. The time spent working on a feature set, or epic, is part of the cost of building or maintaining the feature. I like to look at value as:

Value = Benefit - Cost

If you are providing a feature in the public cloud, your cost may be modeled like this:

Cost = Employee Cost + IaaS Cost

The Pivotal Tracker UI will show you many different ways to analyze data from a given project. One type of data analysis that isn't available from the UI is how much time your team is spending on each epic. This script was created to pull the cycle time for each story so that the data can be aggregated an analyzed. Here is a sample report:

![Image of Sample Report](https://github.com/mjj209/product_manager_tooling/blob/master/QuarterlyAnalysis.png)

# Intro: to use this script the first time...
1. Clone this repo
2. Find your Pivotal Tracker ID, such as `139266`
3. Generate a Pivotal Tracker API Token, such as `fake-0871bd57c489eda6b0aa`
4. Run the script

`ruby PivotalTracker_QuarterlyReport.rb <tracker-id> <pivotal-tracker-token>`

i.e.
`ruby PivotalTracker_QuarterlyReport.rb 139266 fake-0871bd57c489eda6b0aa`

# Second Iteration: Fine tune the tags and story count
Now that you have validated that you can collect the data from your project, you will want to think about the `epic_priority` tags. This is used to 'cleanse' the dataset. If stories have more than 1 tag, you can select which tag should take priority. I put any stories that do not have tags or are not an "epic_priority" into the "maintenance" group.

If stories are missing tags, I would recommend taking 30 mintues to go through your last few months to add missing tags. You can just update the spreadsheet in post-processing, but tagging the source will prevent you from needing to do that next quarter.

You may notice that you are only getting a few weeks worth of stories in the output. You will need to increase the variable `total` so that you get the right amount of data. I usually use `15000` to get 6 months worth of data. 

# Data Analysis
Now that you have a dataset, you can paste it into a spreadsheet to aggregate the story points, story duration, or other metrics.

## duration_hours
Some stories may end up being open for a long time, such as 800 hours. This can throw off the dataset. On my current team, a story may be open & worked on for up to about 2 weeks. Additionally, 85% of stories are open for less than 48 hours. So I will adjust the duration_hours by first normalizing the stories where duration_hours is greater than 48 to be 0-1. Then I will adjust the longest stories to be open for 2 weeks, and so on.


Here are some commons questions I ask myself after I have my cleansed dataset:
1. For each epic that is 10% or more of our time...
 - Is this epic important?
 - Is the time we spent on this epic commensurate with the value provided by the feature?
 - If we spent more time than there is value, what can we do to reduce this time in the next quarter?
 
2. Are there any epics that we spent very little time on, but provide a large amount of value?
- Call these out as wins
- Investigate how we can replicate this for other epics

3. From last quarter, did we actually reduce the amount of time we spent on an epic we believed was low value?

but here, I've updated master

here I've added a change at the bottom of the file
and here's my 2nd commit
