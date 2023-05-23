import MarkdownUI
import SwiftUI
//import RichText
//import HighlightSwift

struct DingusView: View {
    
    let theme: Theme
    
    init() {
        self.theme = Theme.gitHub
            .codeBlock { configuration in
                VStack {
//                    Text("Language: \(configuration.language ?? "none")")
                    
//                    if let lang = configuration.language,
//                       lang == "sym" {
//                        Text("HTML View:").italic()
//                        
////                        RichText(html: configuration.content)
//                        
//                    } else {
//                        CodeCard(configuration.content, style: .stackoverflow)
////                        configuration.label
//                    }
                    
                    
                }
//                .background(.black.opacity(0.1))
                
                
//                ScrollView(.horizontal) {
//                }
//                .frame(maxWidth: .infinity)
                
            }
    }
    
//  @State private var markdown = """
//    ## Try GitHub Flavored Markdown
//
//    You can try **GitHub Flavored Markdown** here.  This dingus is powered
//    by [MarkdownUI](https://github.com/gonzalezreal/MarkdownUI), a native
//    Markdown renderer for SwiftUI.
//
//    1. item one
//    1. item two
//       - sublist
//       - sublist
//    """
    
    @State private var markdown = """
    # HTML Renders
    
    ```
    //What happens if there is a single very very long line that keeps on going and going and going and going. Will it soft wrap? Will it hard wrap? What is the answer? I'm not sure.... let's find out!
    <html>
    <head>
        <style>
            .button-container {
                display: flex;
                flex-wrap: wrap;
                gap: 10px; /* space between buttons */
            }

            .button-container button {
                padding: 10px 20px;
                font-size: 16px;
                background-color: lightgrey; /* default button color */
                color: black; /* default text color */
            }

            .button-container button.clicked {
                background-color: grey; /* clicked button color */
                color: white; /* clicked text color */
            }
        </style>

        <script>
            function postData(url = '', data = {}) {
                return fetch(url, {
                    method: 'POST',
                    mode: 'cors',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(data)
                })
                .then(response => response.json());
            }

            function sendPost(event) {
                const id = event.target.id;
                postData('https://webhook.site/8c4b9838-a957-4057-9f52-a7678807e0cf', { id })
                    .then(data => {
                        console.log(data);
                    })
                    .catch((error) => {
                        console.error('Error:', error);
                    });

                event.target.classList.add('clicked');
            }
        </script>
    </head>
    <body>
        <div class="button-container">
            <button id="button1" type="button" onclick="sendPost(event)">Button 1</button>
            <button id="button2" type="button" onclick="sendPost(event)">Button 2</button>
            <button id="button3" type="button" onclick="sendPost(event)">Button 3</button>
            <button id="button4" type="button" onclick="sendPost(event)">Button 4</button>
            <button id="button5" type="button" onclick="sendPost(event)">Button 5</button>
        </div>
    </body>
    </html>
    
    ```
    
    
    """
    
    
    @State private var markdown2 = """
      ## Try GitHub Flavored Markdown

      ```sym
      
      <h1>Non quam nostram quidem, inquit Pomponius iocans;</h1>
              
      <img src = "https://user-images.githubusercontent.com/73557895/126889699-a735f993-2d95-4897-ae40-bcb932dc23cd.png">
      

      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quis istum dolorem timet? Sit sane ista voluptas. Quis est tam dissimile homini. Duo Reges: constructio interrete. <i>Quam illa ardentis amores excitaret sui! Cur tandem?</i> </p>

      <dl>
          <dt><dfn>Avaritiamne minuis?</dfn></dt>
          <dd>Placet igitur tibi, Cato, cum res sumpseris non concessas, ex illis efficere, quod velis?</dd>
          <dt><dfn>Immo videri fortasse.</dfn></dt>
          <dd>Quae qui non vident, nihil umquam magnum ac cognitione dignum amaverunt.</dd>
          <dt><dfn>Si longus, levis.</dfn></dt>
          <dd>Ita ne hoc quidem modo paria peccata sunt.</dd>
      </dl>


      <ol>
          <li>Possumusne ergo in vita summum bonum dicere, cum id ne in cena quidem posse videamur?</li>
          <li>Placet igitur tibi, Cato, cum res sumpseris non concessas, ex illis efficere, quod velis?</li>
          <li>Unum nescio, quo modo possit, si luxuriosus sit, finitas cupiditates habere.</li>
      </ol>


      <blockquote cite="http://loripsum.net">
          Aristoteles, Xenocrates, tota illa familia non dabit, quippe qui valitudinem, vires, divitias, gloriam, multa alia bona esse dicant, laudabilia non dicant.
      </blockquote>


      <p>Scrupulum, inquam, abeunti; Conferam tecum, quam cuique verso rem subicias; Audeo dicere, inquit. Maximus dolor, inquit, brevis est. Nos commodius agimus. </p>

      <ul>
          <li>Cur igitur, inquam, res tam dissimiles eodem nomine appellas?</li>
          <li>Omnia peccata paria dicitis.</li>
      </ul>


      <h2>Laboro autem non sine causa;</h2>

      <p>Itaque contra est, ac dicitis; <code>Illa argumenta propria videamus, cur omnia sint paria peccata.</code> </p>

      <pre>Nunc dicam de voluptate, nihil scilicet novi, ea tamen, quae
      te ipsum probaturum esse confidam.

      Sin est etiam corpus, ista explanatio naturae nempe hoc
      effecerit, ut ea, quae ante explanationem tenebamus,
      relinquamus.
      </pre>
      
      ```
      
      """

  var body: some View {
    DemoView {
      Section("Editor") {
        TextEditor(text: $markdown)
          .font(.system(.callout, design: .monospaced))
      }

      Section("Preview") {
        Markdown(self.markdown)
              .markdownTheme(theme)
              
      }
    }
  }
}

struct DingusView_Previews: PreviewProvider {
  static var previews: some View {
    DingusView()
  }
}
