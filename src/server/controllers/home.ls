require! "./layout"

exports.render =
  layout.standard """
    <h1>Heyyyyyyyy world, how's it going?!</h1>
    DaMN! I GOT THIS
  """, 
    scripts: <[shared/shared-test.js test-client.js]>
