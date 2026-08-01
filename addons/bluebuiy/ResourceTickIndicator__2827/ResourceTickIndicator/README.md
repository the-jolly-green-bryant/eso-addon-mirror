# ResourceTickIndicator
By bluebuiy

This is an addon for ESO.
Tracks the passive resource restore tick that occurs every 2 seconds.

As of u28, they occur every 2 seconds. But the addon api (as far as I can tell) doesn't have a way to know when a passive tick occurs.  Thus we can only guess by watching all resource restore ticks.  If the amount is equal to the passive regen amount then we can guess that it was the passive tick.  Our guess can also be refined.  If we have a known tick, we know the next tick will occur after the tick period and can ignore any changes outside of that envelope.

### Getting the indicator as accurate as possible

#### Changes in latency
Since I don't know the server tick rate, and latency can be high and vary wildly, we need to correct for that. Assume the client recieves a restore tick when latency is 0, and when it recieves the next tick latency is 100ms.  If the client measures the time between the two ticks, it will see 2050ms! 
<details>
<summary>Why 2050 instead of 2100?</summary>Assume one-way trip time both ways is half the round trip time aka latency aka ping.  Since the server is telling us what happens data only flows one way, and we don't "care" about the time to send data from client to server. But it's impossible to measure one way trip time, so we can only guess that it's half the rtt.  That does add a bit of a wrinkle since we know that the one-way trip time will differ client-server vs server-client.  I deal with that by expanding the envelope a bit.  I think that's ok since it's likely the client doesn't get updates that often.

In this example, the math would be 0/2 + 100/2 = 50ms aditional time in the interval caused by changes to latency.
</details>
Obviously that is longer than the given restore period.  So we need to adjust by the latency differences between the latest known restore tick and current test point.

#### Server-side latency correction
This is when the server looks at your inputs and applies them "back in time", when you made them.  This is usually done in high stakes fps games (overwatch, csgo, valorant are prime examples).  
My observations show that eso **doesn't** do this. And that's fine - it requires a lot of server resources and dev time to get it working well.
What that means is if you stop blocking/sprinting slightly earlier than 2 seconds after the previous tick, you will fail to get the resource tick. This is because the server is recieving your input rtt/2 seconds later, which is past when it checks for the passive tick.  To compensate, the indicator's animation is shortened by rtt/2, measured from the last known good tick. (this is wrong, the animation needs to adjust based on current rtt, but works well enough in most cases and fixed the bad feeling it had initially.)

