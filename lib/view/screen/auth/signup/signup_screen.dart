import 'package:compare_prices/view/screen/auth/signin/signin_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';
import '../../home/home_screen.dart';
class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  final TextEditingController _passwordFieldKey = TextEditingController();

  final _confirmPasswordFieldKey =  GlobalKey<FormBuilderFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormBuilder(
        key: _formKey,
        child:
        Container(
          padding: const EdgeInsets.all(16),
          child:

          Column(
            children: [
              Spacer(),
              Text(
                'Sign Up',
                style: Theme.of(context).textTheme.headline4,
              ),
              Spacer(),
          FormBuilderTextField(
            name: 'company_name',
            decoration: const InputDecoration(labelText: 'Company Name'),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
            ]),
          ),
              const SizedBox(height: 10),

              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                controller: _passwordFieldKey,
                name: 'password',
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 10),
              FormBuilderTextField(
                key: _confirmPasswordFieldKey,
                name: 'confirm_password',
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyText2,
                  children: [
                    TextSpan(
                      text: 'Sign In',
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // navigate to sign in screen
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));

                        },
                    ),
                  ],
                ),
              ),
              Spacer(),
              MaterialButton(
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  // Validate and save the form values
                  if(_formKey.currentState!.saveAndValidate()) {
                    bool passwordMatch = _formKey.currentState
                        ?.value['password'] ==
                        _formKey.currentState?.value['confirm_password'];
                    print(passwordMatch);

                    if (!passwordMatch) {
                      _confirmPasswordFieldKey.currentState?.invalidate(
                          'Passwords do not match');
                    }else{
                      context.read<AuthenticationProvider>().signUp(_formKey.currentState?.value['email'], _formKey.currentState?.value['password'], _formKey.currentState?.value['company_name']).whenComplete(() {
                        print("Sign up complete");
                        print(context.read<AuthenticationProvider>().user);
                        if(context.read<AuthenticationProvider>().user != null){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                        }
                        setState(() {

                        });
                      });

                    }
                  }
                },
                child: context.watch<AuthenticationProvider>().isLoading
                    ?
                    Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                    : const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
